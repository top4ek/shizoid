# frozen_string_literal: true

class Participation < ApplicationRecord
  belongs_to :chat
  belongs_to :user

  scope :scored, -> { where.not(score: 0) }

  def learn(message)
    self.experience += rand(3) if active_at.nil? || 5.minutes.ago > active_at
    self.active_at = Time.current
    self.left = message.left_chat_member&.id == user.id if message.left_chat_member&.id.present?
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

    def learn(message)
      chat = Chat.find_by(telegram_id: message&.chat&.id)
      user = User.find_by(id: message&.from&.id)
      return if chat.nil? || user.nil?

      Participation.find_or_create_by(chat:, user:).learn(message)
    end
  end
end
