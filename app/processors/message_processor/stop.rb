# frozen_string_literal: true

module MessageProcessor
  class Stop
    include Processor

    def responds?
      command == 'stop' && message_from_bot_owner?
    end

    def process!
      chat.disable!
      { send_message: { chat_id: chat.telegram_id, reply_to_message_id: message.message_id, text: ok },
        leave_chat: { chat_id: chat.telegram_id } }
    end
  end
end
