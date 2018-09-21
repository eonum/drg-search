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

ActiveRecord::Schema.define(version: 20160622074615) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "adrgs", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "version"
    t.string "text_de"
    t.string "text_fr"
    t.string "text_it"
    t.integer "partition_id"
    t.integer "mdc_id"
    t.text "relevant_codes_de"
    t.text "relevant_codes_fr"
    t.text "relevant_codes_it"
  end

  create_table "drgs", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "version"
    t.string "text_de"
    t.string "text_fr"
    t.string "text_it"
    t.integer "mdc_id"
    t.integer "partition_id"
    t.integer "adrg_id"
    t.string "partition_letter"
    t.text "relevant_codes_de"
    t.text "relevant_codes_fr"
    t.text "relevant_codes_it"
  end

  create_table "hospitals", id: :serial, force: :cascade do |t|
    t.integer "year"
    t.integer "hospital_id"
    t.string "name"
    t.string "street"
    t.string "address"
    t.string "canton"
  end

  create_table "mdcs", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "version"
    t.string "text_de"
    t.string "text_fr"
    t.string "text_it"
    t.string "prefix"
    t.text "relevant_codes_de"
    t.text "relevant_codes_fr"
    t.text "relevant_codes_it"
    t.string "code_search"
  end

  create_table "num_cases", id: :serial, force: :cascade do |t|
    t.integer "n"
    t.integer "hospital_id"
    t.integer "year"
    t.string "version"
    t.string "level"
    t.string "code"
    t.integer "code_object_id"
    t.string "code_object_type"
  end

  create_table "partitions", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "version"
    t.integer "mdc_id"
  end

  create_table "systems", id: :serial, force: :cascade do |t|
    t.string "version"
    t.integer "years", default: [], array: true
    t.string "text_de"
    t.string "text_fr"
    t.string "text_it"
    t.integer "application_year"
  end

end
