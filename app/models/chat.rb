class Chat < ActiveRecord::Base
  has_many :pairs

  enum chat_type: [:personal, :faction, :supergroup, :channel]

  after_commit :log_creation, on: :create
  before_save :log_new_gab, if: :random_chance_changed?

  def migrate_to_chat_id(new_id)
    Bot.logger.info "[chat #{self.chat_type} #{self.telegram_id}] Migrating ID to #{new_id}"
    self.telegram_id = new_id
    self.save
  end

  def self.get_chat(message)
    chat = message.chat
    telegram_id = chat.id
    type = case chat.type
      when 'private'
        :personal
      when 'group'
        :faction
      else
        chat.type.to_sym
      end
    Chat.find_by(telegram_id: telegram_id, chat_type: chat_types[type]) ||
      Chat.create(telegram_id: telegram_id, chat_type: chat_types[type])
  end

  private

  def log_new_gab
    Bot.logger.info "[chat #{self.chat_type} #{self.telegram_id}] New gab level is set to #{self.random_chance}"
  end

  def log_creation
    Bot.logger.info "[chat #{self.chat_type} #{self.telegram_id}] Created with internal ID #{self.id}"
  end

end
