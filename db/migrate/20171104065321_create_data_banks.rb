class CreateDataBanks < ActiveRecord::Migration[5.1]
  def change
    create_table :data_banks do |t|
      t.string :name, null: false, unique: true
    end
    add_column :chats, :data_bank_ids, :jsonb, null: false, default: []
    add_column :pairs, :data_bank_id, :integer, null: true
    remove_index :pairs, [ :first_id, :second_id, :chat_id ]
    add_index :pairs, [ :first_id, :second_id, :chat_id, :data_bank_id ], unique: true, name: 'pairs_index'
  end
end
