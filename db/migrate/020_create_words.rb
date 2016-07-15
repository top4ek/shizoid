class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :word, null: false, unique: true
    end
    add_index :words, :word, order: { words: :varchar_pattern_ops }
  end
end
