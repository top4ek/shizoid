class PairUpdater
  include Sidekiq::Worker
  sidekiq_options queue: 'learning'

  def perform(options)
    chat = Chat.find_by(id: options['id'])
    Pair.learn(chat_id: chat.id, words: options['words'])
  end
end
