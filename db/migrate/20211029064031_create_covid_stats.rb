# frozen_string_literal: true

class CreateCovidStats < ActiveRecord::Migration[6.1]
  def change
    create_table :covid_stats do |t|
      t.integer :region, null: false
      t.date    :date,   null: false
      t.integer :sick,   null: true
      t.integer :healed, null: true
      t.integer :died,   null: true
      t.integer :first,  null: true
      t.integer :second, null: true

      t.timestamps
    end

    add_index :covid_stats, %i[date region], unique: true
  end
end
