# frozen_string_literal: true

class RemoveCovidStats < ActiveRecord::Migration[7.0]
  def change
    change_table :chats, bulk: true do |t|
      t.remove :covid_region
      t.remove :covid_last_notification
    end
    remove_index :covid_stats, %i[date region], unique: true
    drop_table :covid_stats
  end
end
