# frozen_string_literal: true

class Participation < ApplicationRecord
  belongs_to :chat
  belongs_to :user

  scope :scored, -> { where.not(score: 0) }

  def ban
    Rails.application.secrets[:telegram][:owners].each do |owner_id|
      respose = "CASBAN #{user.to_link} at #{chat.title}"
      # SendPayloadWorker.perform_async(:ban_chat_member, revoke_messages: true, chat_id: chat.telegram_id, user_id: user.id)
      SendPayloadWorker.perform_async('send_message', 'chat_id' => owner_id, 'parse_mode' => 'html', 'text' => respose)
    end
    update!(left: true)
  end

  def learn(message)
    self.experience += rand(3) if active_at.nil? || 5.minutes.ago > active_at
    self.active_at = Time.current
    self.left = message.left_chat_member&.id == user.id
    save!
    self
  end

  # def level
  #   experience / asdasdad
  # end

  class << self
    # def experience_from_level(level)
    #   (level * (level - 1) / 2.to_f) * 100
    # end

    def ban_all
      ban_list = Participation.joins(:chat, :user)
                              .where(participations: { left: false })
                              .where.not(chats: { casbanhammer_at: nil })
                              .where.not(users: { casbanned_at: nil })

      ban_list.each(&:ban)
      ban_list
    end

    def learn(message)
      chat = Chat.find_by(telegram_id: message&.chat&.id)
      user = User.find_by(id: message&.from&.id)
      return if chat.nil? || user.nil?

      Participation.find_or_create_by(chat: chat, user: user).learn(message)
    end
  end
end
