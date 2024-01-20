class RemoveCasBanner < ActiveRecord::Migration[7.0]
  def change
    remove_column :chats, :casbanhammer_at, :datetime, null: true, default: nil

    change_table :users, bulk: true do |t|
      t.remove :casbanned_at
      t.remove :casbanchecked_at
    end
  end
end
