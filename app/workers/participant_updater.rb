class ParticipantUpdater
  include Sidekiq::Worker
  sidekiq_options queue: 'updating'

  def perform(options)
    chat = Chat.find_by(telegram_id: options['chat_id'])
    user = Chat.find_by(telegram_id: options['user_id'])
    return if chat.nil? || user.nil? || options['chat_id'] == options['user_id']
    participation = chat.participations.find_or_create_by(participant_id: user.id)
    participation.present = options['user_id'] != options['left_id']
    participation.save
  end
end
