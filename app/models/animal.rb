class Animal < ApplicationRecord
  # Associations
  belongs_to :home_shelter, class_name: "Shelter", foreign_key: :home_shelter_id

  # Controlled vocabularies
  SPECIES  = %w[dog cat reptile bird other].freeze
  STATUSES = %w[in_shelter in_foster adopted deceased in_transit].freeze
  SEXES    = %w[male female unknown].freeze

  # Validations
  validates :name, presence: true

  validates :species,
            presence: true,
            inclusion: { in: SPECIES }

  validates :sex,
            presence: true,
            inclusion: { in: SEXES }

  validates :status,
            presence: true,
            inclusion: { in: STATUSES }

  validates :intake_date, presence: true
  validates :home_shelter, presence: true

  validates :age_years,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 },
            allow_nil: true

  validates :age_months,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 12 },
            allow_nil: true

  validates :weight,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  validates :microchipped, inclusion: { in: [true, false] }

  # Ensure temperament_tags is always an array
  before_validation :normalize_temperament_tags

  private

  def normalize_temperament_tags
    self.temperament_tags ||= []
  end
end
