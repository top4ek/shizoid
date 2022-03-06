# frozen_string_literal: true

class UpdateProcessor
  def self.call(update)
    message = update['message']
    return if message.blank?

    data = Telegram::Bot::Types::Message.new message
    chat = Chat.learn(data)
    User.learn(data)
    Participation.learn(data)

    queue_name = "chat_#{chat.id}"
    Sidekiq::Queue[queue_name].limit = 1
    MessageWorker.set(queue: queue_name).perform_async(message)
  end
end
