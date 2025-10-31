class Shelter < ApplicationRecord
    has_many :memberships, dependent: :destroy
    has_many :users, through: :memberships

    validates :name, presence: true

    scope :search, ->(q) {
        q.present? ? where(
            "LOWER(name) LIKE :q OR LOWER(address) LIKE :q OR LOWER(contact_email) LIKE :q",
            q: "%#{q.downcase}%"
        ) : all
    }
end
