# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_12_01_224630) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "animals", force: :cascade do |t|
    t.string "name", null: false
    t.integer "age_years"
    t.integer "age_months"
    t.string "species", null: false
    t.string "sex", null: false
    t.decimal "weight", precision: 5, scale: 2
    t.boolean "microchipped", default: false
    t.string "temperament_tags", default: [], array: true
    t.text "bio"
    t.string "status", null: false
    t.date "intake_date", null: false
    t.integer "home_shelter_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["home_shelter_id"], name: "index_animals_on_home_shelter_id"
    t.index ["species"], name: "index_animals_on_species"
    t.index ["status"], name: "index_animals_on_status"
    t.index ["temperament_tags"], name: "index_animals_on_temperament_tags", using: :gin
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "shelter_id", null: false
    t.string "role"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shelter_id"], name: "index_memberships_on_shelter_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "shelters", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "phone"
    t.string "contact_email"
    t.integer "capacity"
    t.integer "vacancies"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "latitude"
    t.float "longitude"
  end

  create_table "transfers", force: :cascade do |t|
    t.bigint "animal_id", null: false
    t.integer "from_shelter_id", null: false
    t.integer "to_shelter_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "requested_at"
    t.datetime "accepted_at"
    t.datetime "rejected_at"
    t.datetime "departed_at"
    t.datetime "arrived_at"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["animal_id"], name: "index_transfers_on_animal_id"
    t.index ["from_shelter_id"], name: "index_transfers_on_from_shelter_id"
    t.index ["to_shelter_id"], name: "index_transfers_on_to_shelter_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "animals", "shelters", column: "home_shelter_id"
  add_foreign_key "memberships", "shelters"
  add_foreign_key "memberships", "users"
  add_foreign_key "transfers", "animals"
  add_foreign_key "transfers", "shelters", column: "from_shelter_id"
  add_foreign_key "transfers", "shelters", column: "to_shelter_id"
end
