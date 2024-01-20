# frozen_string_literal: true

class RemoveCovidStats < ActiveRecord::Migration[7.0]
  def change
    change_table :chats, bulk: true do |t|
      t.remove :covid_region, type: :integer, null: true, default: nil
      t.remove :covid_last_notification, type: :date, null: true
    end

    remove_index :covid_stats, %i[date region], unique: true
    drop_table :covid_stats do |t|
      t.integer :region, null: false
      t.date    :date,   null: false
      t.integer :sick,   null: true
      t.integer :healed, null: true
      t.integer :died,   null: true
      t.integer :first,  null: true
      t.integer :second, null: true

      t.timestamps
    end
  end
end
