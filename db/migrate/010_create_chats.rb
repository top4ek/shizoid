class CreateChats < ActiveRecord::Migration
  def change
    create_table :chats do |t|
      t.integer :telegram_id, null: false, limit: 8
      t.integer :chat_type, null: false, limit: 1
      t.integer :random_chance, null: false, default: 5, limit: 1
      t.timestamps null: false
    end
    add_index :chats, :telegram_id
  end
end
