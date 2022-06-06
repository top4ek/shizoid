# frozen_string_literal: true

class AddCasBans < ActiveRecord::Migration[7.0]
  def change
    add_column :chats, :casbanhammer_at, :datetime, null: true, default: nil
    change_table :users, bulk: true do |t|
      t.datetime :casbanned_at, null: true, default: nil
      t.datetime :casbanchecked_at, null: true, default: nil
    end
  end
end
