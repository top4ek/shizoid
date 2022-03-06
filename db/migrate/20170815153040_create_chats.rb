# frozen_string_literal: true

class CreateChats < ActiveRecord::Migration[5.1]
  def change
    create_table :chats do |t|
      t.integer   :kind,       null: false, limit: 1
      t.boolean   :active,     null: false, default: false
      t.integer   :random,     null: false, default: 0, limit: 1
      t.boolean   :bayan,      null: false, default: false
      t.boolean   :eightball,  null: false, default: false
      t.boolean   :greeting,   null: false, default: false
      t.string    :winner,     null: true,  default: nil
      t.string    :locale,     null: false, default: 'ru', limit: 5
      t.string    :title
      t.string    :first_name
      t.string    :last_name
      t.string    :username
    end
  end
end
