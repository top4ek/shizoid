class Greeting < ApplicationRecord
  belongs_to :chat

  def self.fetch
    get.sample
  end

  def self.list(chat_id)
    Greetings.where(chat_id: chat_id).pluck(:id, :text)
  end

  def self.add(chat_id, greeting)
    Greetings.create(chat_id: chat_id, text: greeting)
  end
end
