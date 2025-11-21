class AddCoordinatesToShelters < ActiveRecord::Migration[8.0]
  def change
    add_column :shelters, :latitude, :float
    add_column :shelters, :longitude, :float
  end
end
