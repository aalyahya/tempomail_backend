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

ActiveRecord::Schema.define(version: 2020_04_15_174949) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "agents", force: :cascade do |t|
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.string "player_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
  end

  create_table "data_migrations", primary_key: "version", id: :string, force: :cascade do |t|
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "owner_id"
    t.string "owner_type"
    t.string "queue"
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "email_addresses", force: :cascade do |t|
    t.string "email", null: false
    t.bigint "agent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "locked_at"
    t.datetime "expire_at"
    t.datetime "deleted_at"
    t.index ["agent_id"], name: "index_email_addresses_on_agent_id"
    t.index ["deleted_at", "email"], name: "index_email_addresses_on_deleted_at_and_email", where: "(deleted_at IS NULL)"
    t.index ["email"], name: "index_email_addresses_on_email", unique: true
    t.index ["locked_at"], name: "index_email_addresses_on_locked_at", where: "(locked_at IS NULL)"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "seqno", null: false
    t.string "message_id", null: false
    t.bigint "email_address_id"
    t.string "date"
    t.string "subject"
    t.jsonb "from", array: true
    t.jsonb "sender", array: true
    t.jsonb "reply_to", array: true
    t.jsonb "to", array: true
    t.jsonb "cc", array: true
    t.jsonb "bcc", array: true
    t.string "in_reply_to"
    t.string "internal_date"
    t.text "rfc822"
    t.text "rfc822_header"
    t.text "rfc822_text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["email_address_id"], name: "index_messages_on_email_address_id"
    t.index ["message_id"], name: "index_messages_on_message_id"
  end

  add_foreign_key "email_addresses", "agents"
  add_foreign_key "messages", "email_addresses"
end
