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

ActiveRecord::Schema.define(version: 2018_07_08_221513) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "affiliates", force: :cascade do |t|
    t.string "name"
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
    t.integer "role"
    t.index ["company_id"], name: "index_clients_on_company_id"
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.integer "record_limit"
    t.date "time_limit"
    t.text "note"
    t.index ["user_id"], name: "index_companies_on_user_id"
  end

  create_table "discounts", force: :cascade do |t|
    t.date "start_at", null: false
    t.date "finish_at", null: false
    t.float "value", null: false
    t.string "note", null: false
    t.boolean "is_active", default: true, null: false
    t.bigint "record_client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_client_id"], name: "index_discounts_on_record_client_id"
  end

  create_table "field_data", force: :cascade do |t|
    t.string "value"
    t.bigint "field_id", null: false
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_field_data_on_client_id"
    t.index ["field_id"], name: "index_field_data_on_field_id"
  end

  create_table "field_templates", force: :cascade do |t|
    t.string "name"
    t.integer "block_id", null: false
    t.string "field_type"
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fin_operations", force: :cascade do |t|
    t.float "amount", null: false
    t.date "operation_date", null: false
    t.integer "operation_type"
    t.integer "operation_object_id"
    t.boolean "is_active", default: true, null: false
    t.text "description"
    t.text "description_cancellation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "affiliate_id"
    t.integer "operation_number"
  end

  create_table "histories", force: :cascade do |t|
    t.string "object_log"
    t.integer "object_id"
    t.string "type_history"
    t.text "note"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_histories_on_user_id"
  end

  create_table "info_blocks", force: :cascade do |t|
    t.string "name"
    t.string "model_object"
    t.integer "company_id", null: false
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.integer "record_type", null: false
    t.integer "visit_type", null: false
    t.string "is_automatic", default: "not", null: false
    t.index ["affiliate_id"], name: "index_records_on_affiliate_id"
  end

  create_table "records_clients", force: :cascade do |t|
    t.boolean "is_active", default: true, null: false
    t.boolean "is_automatic", null: false
    t.boolean "is_dynamic", null: false
    t.bigint "record_id", null: false
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_records_clients_on_client_id"
    t.index ["record_id", "client_id"], name: "index_records_clients_on_record_id_and_client_id", unique: true
    t.index ["record_id"], name: "index_records_clients_on_record_id"
  end

  create_table "records_services", primary_key: ["record_id", "service_id"], force: :cascade do |t|
    t.bigint "record_id", null: false
    t.bigint "service_id", null: false
    t.float "money_for_abon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "money_for_visit"
    t.index ["record_id"], name: "index_records_services_on_record_id"
    t.index ["service_id"], name: "index_records_services_on_service_id"
  end

  create_table "salaries", force: :cascade do |t|
    t.date "start_at", null: false
    t.date "finish_at", null: false
    t.float "pay", null: false
    t.bigint "work_id", null: false
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["work_id"], name: "index_salaries_on_work_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "is_active", default: true, null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_services_on_company_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.date "start_at", null: false
    t.date "finish_at", null: false
    t.integer "visits"
    t.boolean "is_active", default: true, null: false
    t.string "note"
    t.float "price"
    t.bigint "record_client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_client_id"], name: "index_subscriptions_on_record_client_id"
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
    t.integer "people_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "work_salaries", force: :cascade do |t|
    t.string "pay_status", default: "fixed"
    t.float "pay_object", default: 0.0
    t.boolean "is_active", default: true, null: false
    t.integer "work_id", null: false
    t.bigint "record_id"
    t.bigint "affiliate_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["affiliate_id"], name: "index_work_salaries_on_affiliate_id"
    t.index ["record_id"], name: "index_work_salaries_on_record_id"
  end

  create_table "works", force: :cascade do |t|
    t.string "position_work", null: false
    t.float "fixed_rate"
    t.boolean "is_active", default: true
    t.bigint "affiliate_id", null: false
    t.bigint "people_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["affiliate_id"], name: "index_works_on_affiliate_id"
    t.index ["people_id"], name: "index_works_on_people_id"
  end

  add_foreign_key "affiliates", "companies"
  add_foreign_key "clients", "companies"
  add_foreign_key "clients", "users"
  add_foreign_key "companies", "users"
  add_foreign_key "discounts", "records_clients", column: "record_client_id"
  add_foreign_key "histories", "users"
  add_foreign_key "records", "affiliates"
  add_foreign_key "records_clients", "clients"
  add_foreign_key "records_clients", "records"
  add_foreign_key "records_services", "records"
  add_foreign_key "records_services", "services"
  add_foreign_key "services", "companies"
  add_foreign_key "subscriptions", "records_clients", column: "record_client_id"
  add_foreign_key "work_salaries", "affiliates"
  add_foreign_key "work_salaries", "records"
  add_foreign_key "works", "affiliates"
  add_foreign_key "works", "clients", column: "people_id"
end
