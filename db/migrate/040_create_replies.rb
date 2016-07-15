class CreateReplies < ActiveRecord::Migration
  def change
    create_table :replies do |t|
      t.references :pair, null: false
      t.references :word, null: true
      t.integer :count, null: false, default: 1, limit: 8
    end
    add_index :replies, :pair_id
  end
end
