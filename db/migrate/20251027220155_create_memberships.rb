class CreateMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :shelter, null: false, foreign_key: true
      t.string :role
      t.string :status

      t.timestamps
    end
  end
end
