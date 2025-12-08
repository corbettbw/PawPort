class Conversation < ApplicationRecord
  belongs_to :from_shelter, class_name: "Shelter"
  belongs_to :to_shelter,   class_name: "Shelter"
  belongs_to :initiator,    class_name: "User"

  has_many :messages, dependent: :destroy

  validates :subject, presence: true

  scope :for_shelter, ->(shelter) {
    where("from_shelter_id = :id OR to_shelter_id = :id", id: shelter.id)
  }
end
