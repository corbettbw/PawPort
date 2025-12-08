class User < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :shelters, through: :memberships
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :messages, dependent: :nullify  # safe to add now, Message model will come next

  has_many :initiated_conversations,
         class_name: "Conversation",
         foreign_key: :initiator_id,
         dependent: :nullify

  has_many :messages, dependent: :nullify

  def name
    display_name.presence || email
  end
end
