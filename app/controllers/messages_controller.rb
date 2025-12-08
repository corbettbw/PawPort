class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation

  def create
    @message = @conversation.messages.build(message_params.merge(user: current_user))

    if @message.save
      shelter = pick_shelter_for(@conversation)
      redirect_to shelter_path(shelter, tab: "messages"),
                  notice: "Reply sent."
    else
      shelter = pick_shelter_for(@conversation)
      redirect_to shelter_path(shelter, tab: "messages"),
                  alert: @message.errors.full_messages.to_sentence
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def message_params
    params.require(:message).permit(:body)
  end

  def pick_shelter_for(conversation)
    if current_user.memberships.exists?(shelter_id: conversation.to_shelter_id)
      conversation.to_shelter
    else
      conversation.from_shelter
    end
  end
end
