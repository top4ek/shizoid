# frozen_string_literal: true

module MessageProcessor
  class Ids
    include Processor

    def responds?
      command == 'ids'
    end

    def process!
      { send_message: { chat_id: chat.telegram_id,
                        text: response,
                        reply_to_message_id: message.message_id,
                        parse_mode: :markdown } }
    end

    private

    def response
      I18n.t('.ids', type: chat.kind,
                     chat: chat.telegram_id,
                     user: user.id)
    end
  end
end
