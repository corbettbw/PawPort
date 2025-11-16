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
    @shelter = Shelter.find(params[:id])

    if current_user
      @membership = current_user.memberships.find_by(shelter: @shelter)
    end

    @is_member = @membership.present?
  end

  def new
    @shelter = Shelter.new

    if params[:q].present?
      q = params[:q].to_s.strip

      # very light heuristics; harmless if nothing matches
      email  = q[URI::MailTo::EMAIL_REGEXP] rescue nil
      phone  = q[/\+?\d[\d\-\s\(\)]{7,}\d/]&.gsub(/\D/, '') # keep digits
      name_guess = q
        .sub(email.to_s, '')
        .sub(phone.to_s, '')
        .squish.presence

      @shelter.name         ||= name_guess
      @shelter.contact_email ||= email
      @shelter.phone        ||= phone
      @shelter.address      ||= q if q.include?(',') # crude hint for addresses
    end
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


  def browse
    @q = params[:q].to_s.strip
    @shelters = Shelter.search(@q).order(:name)
    @joined_ids = current_user.memberships.pluck(:shelter_id)
  end

  def join
    shelter = Shelter.find(params[:id])
    Membership.find_or_create_by!(user: current_user, shelter: shelter) do |m|
      m.role = "member"
      m.status = "active"
    end
    redirect_to shelters_path, notice: "Joined #{shelter.name}."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to browse_shelters_path(q: params[:q]), alert: e.record.errors.full_messages.to_sentence
  end
  
  def leave
    shelter     = Shelter.find(params[:id])
    membership  = current_user.memberships.find_by!(shelter_id: shelter.id)
    membership.destroy
    redirect_to shelters_path, notice: "Left #{shelter.name}."
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
end