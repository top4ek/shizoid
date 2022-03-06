# frozen_string_literal: true

module MessageProcessor
  class BinaryDice
    include Processor

    def responds?
      super && chat.answer_randomly? && achors?
    end

    def process!
      { send_message: { chat_id: chat.telegram_id,
                        reply_to_message_id: message.message_id,
                        text: I18n.t('binary_dice.answers').sample } }
    end

    private

    def achors?
      text? && text&.chars&.last == '?' && text_words.size > 3 && (text_words & I18n.t('binary_dice.anchors')).any?
    end
  end
end
