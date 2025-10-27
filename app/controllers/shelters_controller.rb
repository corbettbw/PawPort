class SheltersController < ApplicationController
  before_action :set_shelter, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  def index
    @shelters = current_user.shelters.order(created_at: :desc)

    # Until we wire up associations, show the user’s shelters if the
    # association exists; otherwise show none and a clear call-to-action.
    @shelters = current_user.shelters.includes(:memberships, :users).order(created_at: :desc)
  end

  def show
  end

  def new
    @shelter = Shelter.new
  end

  def create
    @shelter = Shelter.new(shelter_params)
    if @shelter.save
      Membership.create!(user: current_user, shelter: @shelter, role: "owner", status: "active")
      redirect_to @shelter, notice: "Shelter created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @shelter.update(shelter_params)
      redirect_to @shelter, notice: "Shelter updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @shelter.destroy
    redirect_to shelters_path, notice: "Shelter deleted."
  end
end

private

def set_shelter
  @shelter = Shelter.find(params[:id])
end

def shelter_params
    params.require(:shelter).permit(
      :name,
      :address,
      :phone,
      :contact_email,
      :capacity,
      :vacancies
    )
end