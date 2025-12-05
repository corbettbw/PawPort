class Transfer < ApplicationRecord
  STATUSES = %w[
    pending     # origin requested, waiting on destination
    accepted    # destination accepted, animal still at origin
    rejected    # destination rejected
    in_transit  # animal physically en route
    completed   # destination received animal
    cancelled   # origin cancelled before completion
  ].freeze

  belongs_to :animal
  belongs_to :from_shelter, class_name: "Shelter"
  belongs_to :to_shelter,   class_name: "Shelter"

  validates :status, inclusion: { in: STATUSES }

  scope :active, -> { where(status: %w[pending accepted in_transit]) }

  # --- Convenience predicates ---

  def pending?     = status == "pending"
  def accepted?    = status == "accepted"
  def rejected?    = status == "rejected"
  def in_transit?  = status == "in_transit"
  def completed?   = status == "completed"
  def cancelled?   = status == "cancelled"

  # --- State transitions ---
  # NOTE: These methods assume you have authorization checks in controllers;
  # here we only enforce status sequencing and keep Animal + vacancies in sync.

  # Destination shelter accepts the request (animal still physically at origin).
  def accept!
    return false unless pending?

    ApplicationRecord.transaction do
      to_shelter.reserve_slot!
      update!(
        status:      "accepted",
        accepted_at: Time.current
      )
    end
  end

  # Destination shelter rejects the request.
  def reject!(reason: nil)
    ApplicationRecord.transaction do
      if accepted?
        to_shelter.release_slot!
      elsif !pending?
        return false
      end

      update!(
        status:      "rejected",
        rejected_at: Time.current,
        notes:       [notes, reason].compact.join("\n\n")
      )
    end
  end

  # Origin marks the animal as having left the building.
  # This:
  # - sets Transfer status -> in_transit
  # - sets Animal status   -> in_transit
  # Animal's callbacks should handle vacancy +1 at origin.
  def mark_in_transit!
    return false unless accepted?

    ApplicationRecord.transaction do
      animal.update!(status: "in_transit")
      update!(
        status:      "in_transit",
        departed_at: Time.current
      )
    end
  end

  # Destination marks the animal as received.
  # This:
  # - sets Transfer status     -> completed
  # - moves Animal home_shelter to to_shelter
  # - sets Animal status       -> in_shelter
  # Animal's callbacks should handle vacancy -1 at destination.
  def mark_received!
    return false unless in_transit? || accepted?

    ApplicationRecord.transaction do
      from_shelter.release_slot!

      animal.update!(
        home_shelter: to_shelter,
        status:       "in_shelter"
      )

      update!(
        status:    "completed",
        arrived_at: Time.current
      )
    end
  end

  # Origin cancels a pending or accepted transfer before the animal leaves.
  # Animal stays where it is; no vacancy change.
  def cancel!(reason: nil)
    ApplicationRecord.transaction do
      if accepted? || in_transit?
        to_shelter.release_slot!
      elsif !pending?
        return false
      end

      # Optionally roll back animal status from in_transit → in_shelter at A if needed.
      if in_transit?
        animal.update!(status: "in_shelter")
      end

      update!(
        status: "cancelled",
        notes:  [notes, reason].compact.join("\n\n")
      )
    end
  end
end
