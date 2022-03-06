# frozen_string_literal: true

module MessageProcessor
  class Say
    include Processor

    def responds?
      super && command == 'say' && message_from_bot_owner?
    end

    def process!
      { delete_message: { chat_id: chat.telegram_id, message_id: message.message_id },
        send_message: payload }
    end

    def payload
      result = { chat_id: chat.telegram_id, text: text_without_command }
      result[:reply_to_message_id] = message.reply_to_message.message_id if message.reply_to_message.present?
      result
    end
  end
end
