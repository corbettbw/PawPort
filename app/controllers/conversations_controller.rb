class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def show
    @conversation = Conversation
        .includes(:from_shelter, :to_shelter, messages: :user)
        .find(params[:id])

    # Pick a shelter context so we can reuse the Messages tab UI.
    shelter = pick_shelter_for(@conversation)
    redirect_to shelter_path(shelter, tab: "messages", conversation_id: @conversation.id)
  end


  def create
    conv_params = conversation_params

    from = Shelter.find(conv_params[:from_shelter_id])
    to   = Shelter.find(conv_params[:to_shelter_id])

    Conversation.transaction do
      conversation = Conversation.create!(
        subject:         conv_params[:subject],
        from_shelter:    from,
        to_shelter:      to,
        initiator:       current_user,
        last_message_at: Time.current
      )

      conversation.messages.create!(
        user: current_user,
        body: conv_params[:body]
      )

       redirect_to shelter_path(from, tab: "messages", conversation_id: conversation.id),
            notice: "Message sent to #{to.name}."
    end
    rescue ActiveRecord::RecordInvalid => e
        redirect_to shelter_path(from, tab: "messages"),
                alert: "Could not send message: #{e.record.errors.full_messages.to_sentence}"
    end

    def destroy
        conv = Conversation.find(params[:id])

        # choose which shelter context to return to
        shelter = pick_shelter_for(conv)

        conv.destroy

        redirect_to shelter_path(shelter, tab: "messages"),
                    notice: "Conversation deleted."
    end


  private

  def conversation_params
    params.require(:conversation).permit(
      :subject,
      :from_shelter_id,
      :to_shelter_id,
      :body
    )
  end

  def pick_shelter_for(conversation)
    # If the current user is only a member of one side, use that.
    if current_user.memberships.exists?(shelter_id: conversation.to_shelter_id)
      conversation.to_shelter
    else
      conversation.from_shelter
    end
  end
end
