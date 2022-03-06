# frozen_string_literal: true

module MessageProcessor
  class Ping
    include Processor

    def responds?
      super && command == 'ping'
    end

    def process!
      { send_message: { chat_id: chat.telegram_id,
                        reply_to_message_id: message.message_id,
                        text: I18n.t('.ping').sample } }
    end
  end
end
