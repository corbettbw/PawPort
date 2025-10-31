class Onboarding::RolesController < ApplicationController
  before_action :authenticate_user!

  def show
  end

  def create
    foster  = params[:foster] == "1"
    shelter = params[:shelter] == "1"

    # Store choice for this session; we'll branch on it
    session[:onboarding_choice] = { foster:, shelter: }

    if foster && shelter
      # pick which flow you want first; here we start with shelter join
      redirect_to new_onboarding_shelters_join_path
    elsif foster
      redirect_to new_onboarding_foster_path
    elsif shelter
      redirect_to new_onboarding_shelters_join_path
    else
      redirect_to onboarding_role_path, alert: "Please choose at least one option."
    end
  end
end
