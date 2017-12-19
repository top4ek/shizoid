class ChatDestroyer
  include Sidekiq::Worker
  sidekiq_options queue: 'deleting'

  def perform(id)
    chat = Chat.find_by(id: id)
    chat.destroy unless chat.nil?
  end
end
