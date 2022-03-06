# frozen_string_literal: true

class ChatTypeChange < ActiveRecord::Migration[5.2]
  def up
    types = %w[private group supergroup channel].freeze

    rename_column :chats, :kind, :old_kind
    add_column :chats, :kind, :string, limit: 32
    Chat.all.each { |chat| chat.update!(kind: types[chat.old_kind]) }
    remove_column :chats, :old_kind
  end

  def down
    types = { 'private' => 0,
              'group' => 1,
              'supergroup' => 2,
              'channel' => 3 }.freeze

    rename_column :chats, :kind, :old_kind
    add_column :chats, :kind, :integer, limit: 1
    Chat.all.each { |chat| chat.update!(kind: types[chat.old_kind]) }
    remove_column :chats, :old_kind
  end
end
