# frozen_string_literal: true

module MessageProcessor
  class Holiday
    include Processor

    def responds?
      false
      # super && command == 'holiday'
    end

    def process!
      # TODO
      response = 'holiday response'
      { send_message: { chat_id: chat.telegram_id, text: response, reply_to_message_id: message.message_id } }
    end
  end
end
