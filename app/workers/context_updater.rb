class ContextUpdater
  include Sidekiq::Worker
  sidekiq_options queue: 'updating'

  def perform(options)
    chat = Chat.find_by(id: options['id'])
    chat.context Word.to_ids(options['words']) unless chat.nil?
  end
end
