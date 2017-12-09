class StatsUpdater
  include Sidekiq::Worker
  sidekiq_options queue: 'updating'

  def perform(options)
    chat = Chat.find_by(id: options['id'])
    Winner.update_stats(chat.id, options['from'], options['count'])
  end
end
