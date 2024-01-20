# frozen_string_literal: true

module Processor
  attr_reader :message

  delegate :new_chat_members, :text, :entities, to: :message

  def initialize(message)
    @message = message
    background_task if respond_to?(:background_task, true)
  end

  def responds?
    Rails.application.secrets[:allow_all].present? || chat.enabled?
  end

  def process
    process! if responds?
  end

  private

  def process!
    raise 'not implemented'
  end

  def text_words
    text&.split
  end

  def text?
    text.present?
  end

  def ok
    I18n.t('.ok').sample
  end

  def nok
    I18n.t('.nok').sample
  end

  def text_without_command
    return text unless command?

    text_words[1..].join(' ')
  end

  def command?
    text&.chars&.first == '/'
  end

  def command
    return nil unless command?

    text_words.first.split('@').first[1..]
  end

  def message_from_bot_owner?
    Rails.application.secrets[:telegram][:owners].include? message.from.id
  end

  def chat
    @chat ||= Chat.find_by! telegram_id: message.chat.id
  end

  def user
    @user ||= User.find message.from.id
  end

  def participation
    @participation ||= Participation.find_by!(chat:, user:)
  end
end
