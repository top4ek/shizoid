# frozen_string_literal: true

module MessageProcessor
  class Status
    include Processor

    def responds?
      super && command == 'status'
    end

    def process!
      { send_message: { chat_id: chat.telegram_id,
                        parse_mode: :markdown,
                        reply_to_message_id: message.message_id,
                        text: response } }
    end

    private

    def response
      I18n.t('.status', version: Rails.configuration.secrets[:release],
                        active: I18n.t(chat.enabled?.to_s),
                        gab: chat.random,
                        pairs: chat.pairs.size,
                        databanks: I18n.t(chat.data_bank_ids.present?.to_s),
                        auto_eightball: I18n.t(chat.eightball?.to_s),
                        winner: chat.winner || I18n.t('.winner.disabled'))
    end
  end
end
