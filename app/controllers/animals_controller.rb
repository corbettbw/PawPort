class AnimalsController < ApplicationController
  before_action :set_shelter_from_nested, only: [:index, :new, :create]
  before_action :set_animal, only: [:show, :edit, :update]



  def index
    @animals = @shelter.animals.order(intake_date: :desc)
  end

  # GET /shelters/:shelter_id/animals/new
  def new
    @animal = Animal.new(
      home_shelter: @shelter,
      status: "in_shelter",
      intake_date: Date.today
    )
  end

  # POST /shelters/:shelter_id/animals
  def create
    @animal = Animal.new(animal_params)
    @animal.home_shelter = @shelter
    @animal.status ||= "in_shelter"
    @animal.intake_date ||= Date.today

    if @animal.save
      if @animal.status == "in_shelter"
        @shelter.decrement!(:vacancies)
      end

      redirect_to animal_path(@animal), notice: "Animal was successfully admitted."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /animals/:id
  def show
    # @animal is set by before_action
  end

  # GET /animals/:id/edit
  def edit
    # @animal is set by before_action
  end

  # PATCH/PUT /animals/:id
  def update
    if @animal.update(animal_params)
      redirect_to animal_path(@animal), notice: "Animal was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_shelter_from_nested
    @shelter = Shelter.find(params[:shelter_id])
  end

  def set_animal
    @animal = Animal.find(params[:id])
  end

  def animal_params
    params.require(:animal).permit(
      :name,
      :age_years,
      :age_months,
      :species,
      :sex,
      :weight,
      :microchipped,
      :bio,
      :status,
      :intake_date,
      temperament_tags: []
    )
  end
end
