class AddParticipations < ActiveRecord::Migration[5.1]
  def change
    create_table :participations do |t|
      t.references :chat, null: false, index: true
      t.references :participant, null: false, index: true
      t.boolean :present, null: false, default: true
      t.timestamps
    end
  end
end
