class Shelter < ApplicationRecord
    has_many :memberships, dependent: :destroy
    has_many :users, through: :memberships

    validates :name, presence: true

    # Numeric integrity
    validates :capacity,  numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :vacancies, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validate  :vacancies_cannot_exceed_capacity

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

    private

    def vacancies_cannot_exceed_capacity
        return if capacity.blank? || vacancies.blank?
        if vacancies > capacity
            errors.add(:vacancies, "can't exceed capacity")
        end
    end
end
