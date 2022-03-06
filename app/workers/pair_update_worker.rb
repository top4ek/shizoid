# frozen_string_literal: true

class PairUpdateWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'learning', retry: false

  def perform(chat_id, text)
    chat = Chat.find(chat_id)

    Pair.learn(chat: chat, words: text.split)
  end
end
