# frozen_string_literal: true

class CreateGreetings < ActiveRecord::Migration[5.1]
  def change
    create_table :greetings do |t|
      t.references :chat, null: false
      t.string     :text, null: false
    end
  end
end
