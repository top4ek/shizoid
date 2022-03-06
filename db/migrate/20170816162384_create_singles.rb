# frozen_string_literal: true

class CreateSingles < ActiveRecord::Migration[5.1]
  def change
    create_table :singles do |t|
      t.references :chat,       null: false
      t.references :word,       null: false
      t.integer    :reply_type, null: true,  limit: 1
      t.string     :reply,      null: false
      t.integer    :count,      null: false, limit: 8, default: 0
    end
    add_index :singles, [ :word_id, :chat_id, :reply_type, :reply ], unique: true
  end
end
