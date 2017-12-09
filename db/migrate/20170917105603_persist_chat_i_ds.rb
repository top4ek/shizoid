class PersistChatIDs < ActiveRecord::Migration[5.1]
  def up
    add_column :chats, :telegram_id, :integer, null: true, limit: 8, unique: true
    Chat.all.each_with_index do |chat, index|
      chat.telegram_id = chat.id
      chat.pairs.update_all(chat_id: index)
      chat.singles.update_all(chat_id: index)
      chat.greetings.update_all(chat_id: index)
      chat.winners.update_all(chat_id: index)
      chat.id = index
      chat.save
    end
    change_column :chats, :telegram_id, :integer, null: false, limit: 8, unique: true
    add_index :chats, :telegram_id, unique: true
  end

  def down
    Chat.all.each do |chat|
      chat.pairs.update_all(chat_id: chat.telegram_id)
      chat.singles.update_all(chat_id: chat.telegram_id)
      chat.greetings.update_all(chat_id: chat.telegram_id)
      chat.winners.update_all(chat_id: chat.telegram_id)
      chat.id = chat.telegram_id
      chat.save
    end
    remove_column :chats, :telegram_id
  end
end
