# frozen_string_literal: true

class CreateReplies < ActiveRecord::Migration[5.1]
  def change
    create_table :replies do |t|
      t.references :pair, null: false
      t.references :word, null: true
      t.integer :count, null: true, default: 0
    end
  end
end
