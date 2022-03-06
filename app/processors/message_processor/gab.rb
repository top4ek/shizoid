# frozen_string_literal: true

module MessageProcessor
  class Gab
    include Processor

    def responds?
      super && command == 'gab'
    end

    def process!
      response = if text_without_command.present?
                   set_gab
                 else
                   level_response chat.random
                 end

      { send_message: { chat_id: chat.telegram_id,
                        parse_mode: :markdown,
                        text: response,
                        reply_to_message_id: message.message_id } }
    end

    private

    def level_response(value)
      I18n.t('.gab.level', chance: value)
    end

    def set_gab
      value = text_without_command.to_i
      if value.in?(0..50)
        chat.update(random: value)
        level_response value
      else
        I18n.t('.gab.error')
      end
    end
  end
end
