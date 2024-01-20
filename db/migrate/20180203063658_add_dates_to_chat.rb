# frozen_string_literal: true

class AddDatesToChat < ActiveRecord::Migration[5.1]
  def up
    change_table :chats, bulk: true do |t|
      t.datetime :created_at, null: false, default: Time.current
      t.datetime :active_at, null: true, default: nil
    end

    Chat.where(active: true).each { |c| c.update(active_at: Time.current) }
    remove_column :chats, :active
  end

  def down
    add_column :chats, :active, :boolean, null: false, default: false
    Chat.where.not(active_at: nil).each { |c| c.update(active: true) }
    change_table :chats, bulk: true do |t|
      t.remove :created_at, type: :datetime, null: false, default: Time.current
      t.remove :active_at, type: :datetime, null: true, default: nil
    end
  end
end
