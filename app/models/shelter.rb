class Shelter < ApplicationRecord
    has_many :memberships, dependent: :destroy
    has_many :users, through: :memberships

    # -------- Geocoding --------
    geocoded_by :address

    # Only geocode when:
    # - the address changed, OR
    # - we don't have coordinates yet
    after_validation :geocode, if: :should_geocode?

    def should_geocode?
        address.present? &&
        (will_save_change_to_address? || latitude.blank? || longitude.blank?)
    end
    # ---------------------------

    validates :name, presence: true

    # Numeric integrity
    validates :capacity,  numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :vacancies, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validate  :vacancies_cannot_exceed_capacity

    geocoded_by :address   # method defined below
    after_validation :geocode , if: :address_changed_for_geocoding?


    # Address + phone
    validates :address, presence: true, length: { minimum: 5 }

    # Basic E.164-ish: optional +, leading 1–9, total 10–15 digits
    VALID_PHONE = /\A\+?[1-9]\d{9,14}\z/

    validates :phone, allow_blank: true, format: { with: VALID_PHONE, message: "must be 10–15 digits (optionally starting with +)" }

    scope :search, ->(q) {
        q.present? ? where(
            "LOWER(name) LIKE :q OR LOWER(address) LIKE :q OR LOWER(contact_email) LIKE :q",
            q: "%#{q.downcase}%"
        ) : all
    }

    def total_capacity
        capacity.to_i
    end

    def total_available
        vacancies.to_i
    end
    
    # Geocoding trigger: only geocode when something in the address changed
    def address_changed_for_geocoding?
        will_save_change_to_address?
    end

    # Distance in miles to another shelter, or nil if either has no coords.
    def distance_to(other)
        return nil if latitude.blank? || longitude.blank? ||
                    other.latitude.blank? || other.longitude.blank?

        Geocoder::Calculations.distance_between(
        [latitude, longitude],
        [other.latitude, other.longitude],
        units: :mi
        )
    end

    private

    def vacancies_cannot_exceed_capacity
        return if capacity.blank? || vacancies.blank?
        if vacancies > capacity
            errors.add(:vacancies, "can't exceed capacity")
        end
    end
end
