# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160113161615) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "invoices", force: :cascade do |t|
    t.integer  "product_id"
    t.date     "booking_date"
    t.string   "billing_country"
    t.integer  "amount_cents"
    t.text     "variants"
    t.integer  "payment_type"
    t.integer  "card_type"
    t.integer  "valid_month"
    t.integer  "valid_year"
    t.string   "security_code"
    t.string   "billing_first_name"
    t.string   "billing_last_name"
    t.string   "currency"
    t.integer  "status",             limit: 2, default: 0
    t.string   "token"
    t.string   "payer_id"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "billing_email"
    t.string   "billing_phone"
  end

  add_index "invoices", ["product_id"], name: "index_invoices_on_product_id", using: :btree

  create_table "locations", force: :cascade do |t|
    t.string   "country",    default: "Malaysia"
    t.string   "state"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "product_attachments", force: :cascade do |t|
    t.integer  "product_id"
    t.string   "attachment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "product_attachments", ["product_id"], name: "index_product_attachments_on_product_id", using: :btree

  create_table "product_categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "payment_type",        limit: 2
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "product_category_id"
    t.integer  "location_id"
    t.text     "description"
    t.text     "highlight"
    t.integer  "price_cents"
    t.integer  "zip"
    t.string   "country"
    t.string   "state"
    t.string   "city"
    t.string   "address"
    t.string   "apt"
    t.integer  "refund_day"
    t.integer  "status",              limit: 2, default: 0
    t.string   "currency"
    t.integer  "refund_percent"
    t.integer  "refundable",          limit: 2, default: 0
    t.integer  "step",                limit: 2, default: 0
  end

  add_index "products", ["user_id"], name: "index_products_on_user_id", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "avatar"
    t.date     "birthday"
    t.integer  "gender",     limit: 2
    t.text     "bio"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree

  create_table "store_images", force: :cascade do |t|
    t.integer  "store_setting_id"
    t.string   "store_img"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "store_images", ["store_setting_id"], name: "index_store_images_on_store_setting_id", using: :btree

  create_table "store_settings", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "store_name"
    t.string   "store_username"
    t.string   "phone_hp"
    t.string   "phone_line"
    t.string   "store_img"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "store_settings", ["user_id"], name: "index_store_settings_on_user_id", using: :btree

  create_table "user_avatars", force: :cascade do |t|
    t.integer  "profile_id"
    t.string   "avatar"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_avatars", ["profile_id"], name: "index_user_avatars_on_profile_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                            default: "", null: false
    t.string   "encrypted_password",               default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                    default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "provider"
    t.string   "uid"
    t.integer  "status",                 limit: 2, default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["provider"], name: "index_users_on_provider", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", using: :btree

  create_table "variants", force: :cascade do |t|
    t.integer  "product_id"
    t.string   "name"
    t.integer  "price_cents"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "variants", ["product_id"], name: "index_variants_on_product_id", using: :btree

end
