class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.string :subject

      t.references :from_shelter,
                   null: false,
                   foreign_key: { to_table: :shelters }

      t.references :to_shelter,
                   null: false,
                   foreign_key: { to_table: :shelters }

      t.references :initiator,
                   null: false,
                   foreign_key: { to_table: :users }

      t.datetime :last_message_at

      t.timestamps
    end
  end
end
