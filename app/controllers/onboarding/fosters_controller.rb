class Onboarding::FostersController < ApplicationController
  before_action :authenticate_user!

  def new
    @foster_profile = current_user.foster_profile || current_user.build_foster_profile
  end

  def create
    @foster_profile = current_user.foster_profile || current_user.build_foster_profile
    if @foster_profile.update(foster_params)
      choice = session[:onboarding_choice] || {}
      if choice["shelter"] == true || choice[:shelter] == true
        redirect_to onboarding_shelters_join_path, notice: "Foster profile saved."
      else
        redirect_to onboarding_done_path, notice: "Foster profile saved."
      end
    else
      flash.now[:alert] = "Please fix the errors."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def foster_params
    params.require(:foster_profile).permit(:city, :housing_type, :availability)
  end
end
