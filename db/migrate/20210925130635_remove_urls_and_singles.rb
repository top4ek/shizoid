# frozen_string_literal: true

class RemoveUrlsAndSingles < ActiveRecord::Migration[6.1]
  def change
    drop_table :urls do |t|
      t.string :url, null: false, unique: true, index: true
    end

    drop_table :singles do |t|
      t.references :chat,       null: false
      t.references :word,       null: false
      t.integer    :reply_type, null: true,  limit: 1
      t.string     :reply,      null: false
      t.integer    :count,      null: false, limit: 8, default: 0
    end
  end
end
