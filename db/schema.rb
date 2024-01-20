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

ActiveRecord::Schema[7.0].define(version: 2024_01_20_084922) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chats", force: :cascade do |t|
    t.integer "random", limit: 2, default: 0, null: false
    t.boolean "bayan", default: false, null: false
    t.boolean "eightball", default: false, null: false
    t.boolean "greeting", default: false, null: false
    t.string "winner"
    t.string "locale", limit: 5, default: "ru", null: false
    t.string "title"
    t.string "first_name"
    t.string "last_name"
    t.string "username"
    t.bigint "telegram_id", null: false
    t.jsonb "data_bank_ids", default: [], null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "active_at", precision: nil
    t.string "kind", limit: 32
    t.date "date"
    t.index ["telegram_id"], name: "index_chats_on_telegram_id", unique: true
  end

  create_table "data_banks", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "greetings", force: :cascade do |t|
    t.bigint "chat_id", null: false
    t.string "text", null: false
    t.index ["chat_id"], name: "index_greetings_on_chat_id"
  end

  create_table "pairs", force: :cascade do |t|
    t.bigint "chat_id"
    t.bigint "first_id"
    t.bigint "second_id"
    t.integer "data_bank_id"
    t.index ["chat_id"], name: "index_pairs_on_chat_id"
    t.index ["first_id", "second_id", "chat_id", "data_bank_id"], name: "pairs_index", unique: true
    t.index ["first_id"], name: "index_pairs_on_first_id"
    t.index ["second_id"], name: "index_pairs_on_second_id"
  end

  create_table "participations", force: :cascade do |t|
    t.bigint "chat_id", null: false
    t.bigint "user_id", null: false
    t.boolean "left", default: false, null: false
    t.datetime "active_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "experience", default: 0, null: false
    t.integer "score", default: 0, null: false
    t.index ["chat_id", "user_id"], name: "index_participations_on_chat_id_and_user_id", unique: true
    t.index ["chat_id"], name: "index_participations_on_chat_id"
    t.index ["user_id"], name: "index_participations_on_user_id"
  end

  create_table "replies", force: :cascade do |t|
    t.bigint "pair_id", null: false
    t.bigint "word_id"
    t.integer "count", default: 0
    t.index ["pair_id"], name: "index_replies_on_pair_id"
    t.index ["word_id"], name: "index_replies_on_word_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "is_bot"
    t.string "first_name"
    t.string "last_name"
    t.string "username"
    t.string "language_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "winners", force: :cascade do |t|
    t.bigint "chat_id", null: false
    t.bigint "user_id", null: false
    t.date "created_at", null: false
    t.date "date", null: false
    t.index ["chat_id", "date"], name: "index_winners_on_chat_id_and_date", unique: true
    t.index ["chat_id"], name: "index_winners_on_chat_id"
    t.index ["created_at"], name: "index_winners_on_created_at"
    t.index ["user_id"], name: "index_winners_on_user_id"
  end

  create_table "words", force: :cascade do |t|
    t.string "word", null: false
    t.index ["word"], name: "index_words_on_word", opclass: :varchar_pattern_ops
  end

end
