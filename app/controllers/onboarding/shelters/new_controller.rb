class Onboarding::Shelters::NewController < ApplicationController
  before_action :authenticate_user!

  def new
    @shelter = Shelter.new
  end

  def create
    @shelter = Shelter.new(shelter_params.merge(status: "provisional"))
    if @shelter.save
      current_user.memberships.create!(shelter: @shelter, role: :owner, state: :active)
      redirect_to onboarding_done_path, notice: "Shelter created (provisional)."
    else
      flash.now[:alert] = "Please fix the errors."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def shelter_params
    params.require(:shelter).permit(:name, :website, :location)
  end
end
