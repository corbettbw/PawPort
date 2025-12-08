class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  validates :body, presence: true

  after_create_commit :touch_conversation_timestamp

  private

  def touch_conversation_timestamp
    conversation.update!(last_message_at: Time.current)
  end
end
