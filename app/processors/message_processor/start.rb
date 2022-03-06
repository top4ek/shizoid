# frozen_string_literal: true

module MessageProcessor
  class Start
    include Processor

    def responds?
      command == 'start' && message_from_bot_owner?
    end

    def process!
      chat.enable!
      { send_message: { chat_id: chat.telegram_id, reply_to_message_id: message.message_id, text: ok } }
    end
  end
end
