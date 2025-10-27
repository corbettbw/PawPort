class Onboarding::Shelters::JoinController < ApplicationController
  before_action :authenticate_user!

  def new
    @shelters = Shelter.order(:name).limit(50)
  end

  def create
    invite_code = params[:invite_code].presence
    shelter_id  = params[:shelter_id].presence

    if invite_code
      # For now, just create a pending membership tagged with the invite_code.
      membership = current_user.memberships.create(invite_code:, shelter: Shelter.first) # replace lookup later
      return redirect_to onboarding_done_path, notice: "Join request submitted." if membership.persisted?
    elsif shelter_id
      membership = current_user.memberships.create(shelter_id:, state: :pending)
      return redirect_to onboarding_done_path, notice: "Join request submitted." if membership.persisted?
    end

    flash.now[:alert] = "Select a shelter or enter a valid invite code."
    @shelters = Shelter.order(:name).limit(50)
    render :new, status: :unprocessable_entity
  end
end
