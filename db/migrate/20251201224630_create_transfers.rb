class CreateTransfers < ActiveRecord::Migration[8.0]
  def change
    create_table :transfers do |t|
      t.references :animal, null: false, foreign_key: true
      t.integer :from_shelter_id, null: false
      t.integer :to_shelter_id, null: false
      t.string :status, null: false, default: "pending"
      t.datetime :requested_at
      t.datetime :accepted_at
      t.datetime :rejected_at
      t.datetime :departed_at
      t.datetime :arrived_at
      t.text :notes

      t.timestamps
    end
    
    add_index :transfers, :from_shelter_id
    add_index :transfers, :to_shelter_id

    add_foreign_key :transfers, :shelters, column: :from_shelter_id
    add_foreign_key :transfers, :shelters, column: :to_shelter_id
  end
end
