# frozen_string_literal: true

class AddUsers < ActiveRecord::Migration[6.0]
  def up
    create_table  :users do |t|
      t.boolean   :is_bot
      t.string    :first_name
      t.string    :last_name
      t.string    :username
      t.string    :language_code, default: nil
      t.timestamps
    end
    Chat.where(kind: 'private').find_each do |chat|
      User.create id: chat.telegram_id,
                  is_bot: false,
                  first_name: chat.first_name,
                  last_name: chat.last_name,
                  username: chat.first_name,
                  language_code: nil
    end
    rename_column :participations, :participant_id, :user_id
  end

  def down
    User.all.find_each do |user|
      chat = Chat.find_by(telegram_id: user.id) || Chat.new(telegram_id: user.id, kind: 'private')
      chat.first_name = user.first_name
      chat.last_name = user.last_name
      chat.username = user.first_name
      chat.telegram_id = user.id
      chat.save
    end
    drop_table :users
    rename_column :participations, :user_id, :participant_id
  end
end
