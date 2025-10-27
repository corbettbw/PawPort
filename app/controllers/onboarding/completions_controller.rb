class Onboarding::CompletionsController < ApplicationController
  before_action :authenticate_user!

  def show
    # Clear choice; user is onboarded now if they have any role attached
    session.delete(:onboarding_choice)

    # In the future, route based on context (foster vs shelter). For now:
    redirect_to root_path, notice: "You're all set!"
  end
end
