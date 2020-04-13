# frozen_string_literal: true
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_04_13_172306) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agents", force: :cascade do |t|
    t.string "session_id", null: false
    t.string "player_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
  end

  create_table "data_migrations", primary_key: "version", id: :string, force: :cascade do |t|
  end

  create_table "email_addresses", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "locked_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.bigint "agent_id"
    t.index ["agent_id"], name: "index_email_addresses_on_agent_id"
    t.index ["deleted_at", "email"], name: "index_email_addresses_on_deleted_at_and_email", where: "(deleted_at IS NULL)"
    t.index ["email"], name: "index_email_addresses_on_email", unique: true
    t.index ["locked_at"], name: "index_email_addresses_on_locked_at", where: "(locked_at IS NULL)"
  end

  add_foreign_key "email_addresses", "agents"
end
