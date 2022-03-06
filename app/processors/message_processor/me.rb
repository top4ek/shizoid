# frozen_string_literal: true

module MessageProcessor
  class Me
    include Processor

    def responds?
      super && command == 'me'
    end

    def process!
      { delete_message: { chat_id: chat.telegram_id, message_id: message.message_id },
        send_message: payload }
    end

    def payload
      result = { chat_id: chat.telegram_id, parse_mode: :html, text: reaction }
      result[:reply_to_message_id] = message.reply_to_message.message_id if message.reply_to_message.present?

      result
    end

    def reaction
      return "#{user.to_link} #{text_without_command}" if text_without_command.present?

      "#{user.to_link} #{I18n.t('.me').sample}"
    end
  end
end
