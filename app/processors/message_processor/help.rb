# frozen_string_literal: true

module MessageProcessor
  class Help
    include Processor

    def responds?
      super && command == 'help'
    end

    def process!
      { send_message: { chat_id: chat.telegram_id,
                        text: I18n.t('.help'),
                        parse_mode: :markdown,
                        reply_to_message_id: message.message_id } }
    end
  end
end
