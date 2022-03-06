# frozen_string_literal: true

module MessageProcessor
  class Text
    include Processor

    def responds?
      super &&
        text? &&
        !command? &&
        respond_to_message? &&
        response_text.present?
    end

    def process!
      { send_message: { chat_id: chat.telegram_id,
                        text: response_text,
                        reply_to_message_id: message.message_id } }
    end

    private

    def respond_to_message?
      message&.reply_to_message&.from&.id == TelegramService.bot_id ||
        anchors? ||
        chat.answer_randomly? ||
        chat.kind == 'private'
    end

    def response_text
      @response_text ||= chat.generate_reply(text.split)
    end

    def anchors?
      (text_words & I18n.t('.text.anchors')).any?
    end

    def background_task
      return unless text? && !command? && chat.enabled?

      PairUpdateWorker.perform_async(chat.id, text)

      chat.context Word.to_ids(text_words) if text_words&.any?
    end
  end
end
