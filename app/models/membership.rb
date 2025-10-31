class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :shelter

  validates :user_id, uniqueness: { scope: :shelter_id }

end
