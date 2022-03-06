# frozen_string_literal: true

class AddRegionToChat < ActiveRecord::Migration[6.1]
  def change
    change_table :chats, bulk: true do |t|
      t.integer :covid_region, null: true, default: nil
      t.date    :covid_last_notification, :date, null: true
    end
  end
end
