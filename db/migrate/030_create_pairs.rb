class CreatePairs < ActiveRecord::Migration
  def change
    create_table :pairs do |t|
      t.references :chat, null: false
      t.references :first, null: true
      t.references :second, null: true
      t.timestamp :created_at, null: false
    end
  add_index :pairs, :chat_id
  add_index :pairs, :first_id
  add_index :pairs, :second_id
  end
end
