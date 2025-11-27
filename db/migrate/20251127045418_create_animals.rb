class CreateAnimals < ActiveRecord::Migration[8.0]
  def change
    create_table :animals do |t|
      t.string :name, null: false
      t.integer :age_years
      t.integer :age_months
      t.string :species, null: false
      t.string :sex, null: false
      t.decimal :weight, precision: 5, scale: 2
      t.boolean :microchipped, default: false
      t.string :temperament_tags, array: true, default: []
      t.text :bio
      t.string :status, null: false
      t.date :intake_date, null: false
      t.integer :home_shelter_id, null: false

      t.timestamps
    end
    
    add_index :animals, :home_shelter_id
    add_index :animals, :status
    add_index :animals, :species
    add_index :animals, :temperament_tags, using: :gin
    add_foreign_key :animals, :shelters, column: :home_shelter_id
  end
end
