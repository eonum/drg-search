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

ActiveRecord::Schema.define(version: 20160616183630) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "adrgs", force: :cascade do |t|
    t.string  "code"
    t.string  "version"
    t.string  "text_de"
    t.string  "text_fr"
    t.string  "text_it"
    t.integer "partition_id"
    t.integer "mdc_id"
    t.text    "relevant_codes_de"
    t.text    "relevant_codes_fr"
    t.text    "relevant_codes_it"
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.integer  "visit_id"
    t.integer  "user_id"
    t.string   "name"
    t.json     "properties"
    t.datetime "time"
  end

  add_index "ahoy_events", ["name", "time"], name: "index_ahoy_events_on_name_and_time", using: :btree
  add_index "ahoy_events", ["user_id", "name"], name: "index_ahoy_events_on_user_id_and_name", using: :btree
  add_index "ahoy_events", ["visit_id", "name"], name: "index_ahoy_events_on_visit_id_and_name", using: :btree

  create_table "drgs", force: :cascade do |t|
    t.string  "code"
    t.string  "version"
    t.string  "text_de"
    t.string  "text_fr"
    t.string  "text_it"
    t.integer "mdc_id"
    t.integer "partition_id"
    t.integer "adrg_id"
    t.string  "partition_letter"
    t.text    "relevant_codes_de"
    t.text    "relevant_codes_fr"
    t.text    "relevant_codes_it"
  end

  create_table "hospitals", force: :cascade do |t|
    t.integer "year"
    t.integer "hospital_id"
    t.string  "name"
    t.string  "street"
    t.string  "address"
    t.string  "canton"
  end

  create_table "mdcs", force: :cascade do |t|
    t.string "code"
    t.string "version"
    t.string "text_de"
    t.string "text_fr"
    t.string "text_it"
    t.string "prefix"
    t.text   "relevant_codes_de"
    t.text   "relevant_codes_fr"
    t.text   "relevant_codes_it"
    t.string "code_search"
  end

  create_table "num_cases", force: :cascade do |t|
    t.integer "n"
    t.integer "hospital_id"
    t.integer "year"
    t.string  "version"
    t.string  "level"
    t.string  "code"
  end

  create_table "partitions", force: :cascade do |t|
    t.string  "code"
    t.string  "version"
    t.integer "mdc_id"
  end

  create_table "systems", force: :cascade do |t|
    t.string  "version"
    t.integer "years",            default: [], array: true
    t.string  "text_de"
    t.string  "text_fr"
    t.string  "text_it"
    t.integer "application_year"
  end

  create_table "visits", force: :cascade do |t|
    t.string   "visit_token"
    t.string   "visitor_token"
    t.string   "ip"
    t.text     "user_agent"
    t.text     "referrer"
    t.text     "landing_page"
    t.integer  "user_id"
    t.string   "referring_domain"
    t.string   "search_keyword"
    t.string   "browser"
    t.string   "os"
    t.string   "device_type"
    t.integer  "screen_height"
    t.integer  "screen_width"
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.string   "postal_code"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.string   "utm_source"
    t.string   "utm_medium"
    t.string   "utm_term"
    t.string   "utm_content"
    t.string   "utm_campaign"
    t.datetime "started_at"
  end

  add_index "visits", ["user_id"], name: "index_visits_on_user_id", using: :btree
  add_index "visits", ["visit_token"], name: "index_visits_on_visit_token", unique: true, using: :btree

end
