class SheltersController < ApplicationController
  before_action :set_shelter, only: [:show, :edit, :update, :destroy, :leave]
  before_action :authenticate_user!

  def index
    # list shelters current_user belongs to
    @shelters = current_user.shelters
                            .includes(:memberships, :users)
                            .order(created_at: :desc)
  end

  def show
    # @shelter set by before_action

    if current_user
      @membership = current_user.memberships.find_by(shelter: @shelter)
    end
    @is_member = @membership.present?

    @open_transfer_count = @shelter.outgoing_transfers.active.count + @shelter.incoming_transfers.active.count

    allowed_tabs = %w[home network transfers messages settings]
    @tab = params[:tab].presence_in(allowed_tabs) || "home"

    case @tab
    when "network"
      load_network_shelters
    when "transfers"
      load_transfers_tab
    end
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

      @shelter.name          ||= name_guess
      @shelter.contact_email ||= email
      @shelter.phone         ||= phone
      @shelter.address       ||= q if q.include?(',') # crude hint for addresses
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
    shelter    = Shelter.find(params[:id])
    membership = current_user.memberships.find_by!(shelter_id: shelter.id)
    membership.destroy
    redirect_to shelters_path, notice: "Left #{shelter.name}."
  end

  private

  def load_network_shelters
    scope = Shelter.where.not(id: @shelter.id)

    if params[:only_with_vacancies] == "1"
      scope = scope.where("vacancies > 0")
    end

    shelters = scope.to_a

    @network_shelters = shelters.sort_by do |s|
      case params[:sort]
      when "distance"
        if s.latitude && s.longitude && @shelter.latitude && @shelter.longitude
          s.distance_to(@shelter)
        else
          Float::INFINITY
        end
      when "vacancy"
        -s.total_available          # higher vacancies first
      when "capacity"
        -s.total_capacity           # higher capacity first
      else
        s.name                      # fallback: alphabetical
      end
    end
  end

  def load_transfers_tab
    # Animals at this shelter that can be sent
    @transfer_animals = @shelter.animals
                                .where(status: "in_shelter")
                                .order(:name)

    # Possible destinations (all other shelters)
    @transfer_targets = Shelter.where.not(id: @shelter.id)
                               .order(:name)

    # Transfers where this shelter is the origin
    @outgoing_transfers = @shelter.outgoing_transfers
                                  .active
                                  .includes(:animal, :to_shelter)
                                  .order(created_at: :desc)

    # Transfers where this shelter is the destination
    @incoming_transfers = @shelter.incoming_transfers
                                  .active
                                  .includes(:animal, :from_shelter)
                                  .order(created_at: :desc)
  end

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
