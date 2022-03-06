# frozen_string_literal: true

module MessageProcessor
  class CoolStory
    include Processor

    def responds?
      super && command == 'cool_story'
    end

    def process!
      { send_message: { chat_id: chat.telegram_id,
                        reply_to_message_id: message.message_id,
                        text: response } }
    end

    private

    def response
      if chat.answer_randomly?(50)
        chat.generate_story
      else
        I18n.t('cool_story.lazy').sample
      end
    end
  end
end
