# frozen_string_literal: true

class CreateWords < ActiveRecord::Migration[5.1]
  def change
    create_table :words do |t|
      t.string :word, null: false, unique: true
    end
    add_index :words, :word, order: { words: :varchar_pattern_ops }
  end
end
