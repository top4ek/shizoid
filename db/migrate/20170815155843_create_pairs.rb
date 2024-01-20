# frozen_string_literal: true

class CreatePairs < ActiveRecord::Migration[5.1]
  def change
    create_table :pairs do |t|
      t.references :chat, null: true
      t.references :first, null: true
      t.references :second, null: true
    end
    add_index :pairs, %i[first_id second_id chat_id], unique: true
  end
end
