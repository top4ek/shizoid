# frozen_string_literal: true

class AddDateToWinner < ActiveRecord::Migration[6.1]
  def change
    add_column :winners, :date, :date, null: true
    Winner.find_each { |w| w.update!(date: w.created_at.to_date) }
    change_column_null :winners, :date, false
    add_index :winners, %i[chat_id date], unique: true
  end
end
