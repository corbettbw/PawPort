class TransfersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transfer, only: [:accept, :reject, :mark_in_transit, :mark_received, :cancel]

  ORIGIN_ACTIONS      = %w[mark_in_transit cancel].freeze
  DESTINATION_ACTIONS = %w[accept reject mark_received].freeze

  # POST /transfers
  # Params:
  #   from_shelter_id
  #   transfer[animal_id]
  #   transfer[to_shelter_id]
  def create
    @from_shelter = Shelter.find(params[:from_shelter_id])
    @animal       = @from_shelter.animals.find(transfer_params[:animal_id])
    @to_shelter   = Shelter.find(transfer_params[:to_shelter_id])

    @transfer = Transfer.new(
        animal:       @animal,
        from_shelter: @from_shelter,
        to_shelter:   @to_shelter,
        status:       "pending",
        requested_at: Time.current
    )

    if @transfer.save
        redirect_to shelter_path(@from_shelter, tab: "transfers"),
                    notice: "Transfer request sent to #{@to_shelter.name}."
    else
        redirect_to shelter_path(@from_shelter, tab: "transfers"),
                    alert: "Could not create transfer: #{@transfer.errors.full_messages.to_sentence}"
    end
  end

  # PATCH /transfers/:id/accept
  def accept
    # TODO: later, enforce that current_user belongs to @transfer.to_shelter
    @transfer.accept!
    redirect_back_to_transfers notice: "Transfer accepted."
  rescue => e
    redirect_back_to_transfers alert: "Could not accept transfer: #{e.message}"
  end

  # PATCH /transfers/:id/reject
  def reject
    @transfer.reject!(reason: "Rejected by destination")
    redirect_back_to_transfers notice: "Transfer rejected."
  rescue => e
    redirect_back_to_transfers alert: "Could not reject transfer: #{e.message}"
  end

  # PATCH /transfers/:id/mark_in_transit
  def mark_in_transit
    # TODO: later, enforce that current_user belongs to @transfer.from_shelter
    @transfer.mark_in_transit!
    redirect_back_to_transfers notice: "Animal marked as in transit."
  rescue => e
    redirect_back_to_transfers alert: "Could not mark in transit: #{e.message}"
  end

  # PATCH /transfers/:id/mark_received
  def mark_received
    @transfer.mark_received!
    redirect_back_to_transfers notice: "Animal marked as received."
  rescue => e
    redirect_back_to_transfers alert: "Could not mark received: #{e.message}"
  end

  # PATCH /transfers/:id/cancel
  def cancel
    @transfer.cancel!(reason: "Cancelled by origin")
    redirect_back_to_transfers notice: "Transfer cancelled."
  rescue => e
    redirect_back_to_transfers alert: "Could not cancel transfer: #{e.message}"
  end

  private

  def transfer_params
    params.require(:transfer).permit(:animal_id, :to_shelter_id)
  end

  def set_transfer
    @transfer = Transfer.find(params[:id])
  end

  def redirect_back_to_transfers(flash = {})
    shelter =
      if ORIGIN_ACTIONS.include?(action_name)
        @transfer.from_shelter
      else
        @transfer.to_shelter
      end

    redirect_to shelter_path(shelter, tab: "transfers"), flash
  end
end
