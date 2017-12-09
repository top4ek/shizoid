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

ActiveRecord::Schema.define(version: 20171104065321) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chats", force: :cascade do |t|
    t.integer "kind", limit: 2, null: false
    t.boolean "active", default: false, null: false
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

  create_table "replies", force: :cascade do |t|
    t.bigint "pair_id", null: false
    t.bigint "word_id"
    t.integer "count", default: 0
    t.index ["pair_id"], name: "index_replies_on_pair_id"
    t.index ["word_id"], name: "index_replies_on_word_id"
  end

  create_table "singles", force: :cascade do |t|
    t.bigint "chat_id", null: false
    t.bigint "word_id", null: false
    t.integer "reply_type", limit: 2
    t.string "reply", null: false
    t.bigint "count", default: 0, null: false
    t.index ["chat_id"], name: "index_singles_on_chat_id"
    t.index ["word_id", "chat_id", "reply_type", "reply"], name: "index_singles_on_word_id_and_chat_id_and_reply_type_and_reply", unique: true
    t.index ["word_id"], name: "index_singles_on_word_id"
  end

  create_table "urls", force: :cascade do |t|
    t.string "url", null: false
    t.index ["url"], name: "index_urls_on_url", unique: true
  end

  create_table "winners", force: :cascade do |t|
    t.bigint "chat_id", null: false
    t.bigint "user_id", null: false
    t.date "created_at", null: false
    t.index ["chat_id"], name: "index_winners_on_chat_id"
    t.index ["created_at"], name: "index_winners_on_created_at"
    t.index ["user_id"], name: "index_winners_on_user_id"
  end

  create_table "words", force: :cascade do |t|
    t.string "word", null: false
    t.index ["word"], name: "index_words_on_word"
  end

end
