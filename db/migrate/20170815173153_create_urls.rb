class CreateUrls < ActiveRecord::Migration[5.1]
  def change
    create_table :urls do |t|
      t.string :url, null: false, unique: true
    end
    add_index :urls, :url, unique: true
  end
end
