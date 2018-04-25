# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_04_25_133527) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "affiliates", force: :cascade do |t|
    t.string "name", null: false
    t.string "address", null: false
    t.string "phone_number"
    t.string "email"
    t.bigint "company_id", null: false
    t.index ["company_id"], name: "index_affiliates_on_company_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "patronymic"
    t.date "birthday"
    t.string "phone_number"
    t.bigint "company_id", null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "archive", default: false, null: false
    t.integer "sex", null: false
    t.string "avatar"
    t.index ["company_id"], name: "index_clients_on_company_id"
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_companies_on_user_id"
  end

  create_table "records", force: :cascade do |t|
    t.string "name", null: false
    t.integer "abon_period"
    t.integer "total_clients"
    t.integer "total_visits"
    t.date "finished_at"
    t.bigint "affiliate_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["affiliate_id"], name: "index_records_on_affiliate_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "is_active", default: true, null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_services_on_company_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "patronymic"
    t.date "birthday"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "role", default: 0, null: false
    t.string "avatar"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "affiliates", "companies"
  add_foreign_key "clients", "companies"
  add_foreign_key "clients", "users"
  add_foreign_key "companies", "users"
  add_foreign_key "records", "affiliates"
  add_foreign_key "services", "companies"
end
