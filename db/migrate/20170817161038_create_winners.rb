class CreateWinners < ActiveRecord::Migration[5.1]
  def change
    create_table :winners do |t|
      t.references :chat,       null: false
      t.references :user,       null: false
      t.date       :created_at, null: false
    end
    add_index :winners, :created_at
  end
end
