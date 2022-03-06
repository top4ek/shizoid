# frozen_string_literal: true

class AddParticipations < ActiveRecord::Migration[5.1]
  def change
    create_table :participations do |t|
      t.references :chat, null: false, index: true
      t.references :participant, null: false, index: true
      t.boolean    :left, null: false, default: false
      t.timestamp  :active_at, null: true, default: nil
      t.timestamps
    end
  end
end
