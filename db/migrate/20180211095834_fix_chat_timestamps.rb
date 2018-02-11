class FixChatTimestamps < ActiveRecord::Migration[5.1]
  def change
    change_column_default :chats, :created_at, nil
  end
end
