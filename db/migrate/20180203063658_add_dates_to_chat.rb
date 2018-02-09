class AddDatesToChat < ActiveRecord::Migration[5.1]
  def up
    add_column :chats, :created_at, :datetime, null: false, default: Time.now
    add_column :chats, :active_at, :datetime, null: true, default: nil
    Chat.where(active: true).each { |c| c.update(active_at: Time.now) }
    remove_column :chats, :active
  end

  def down
    add_column :chats, :active, :boolean, null: false, default: false
    Chat.where.not(active_at: nil).each { |c| c.update(active: true) }
    remove_column :chats, :active_at
    remove_column :chats, :created_at
  end
end
