# frozen_string_literal: true

module MessageProcessor
  class Eightball
    include Processor
    include CommandParameters

    def responds?
      super && (command == 'eightball' || autoreact?)
    end

    def process!
      response = case command_parameters
                 when 'enable', 'on'
                   enable
                 when 'disable', 'off'
                   disable
                 else
                   generate_prediction
                 end

      { send_message: { chat_id: chat.telegram_id, reply_to_message_id: message.message_id, text: response } }
    end

    private

    def autoreact?
      text? && text.chars.last == '?' && chat.eightball? && chat.answer_randomly?
    end

    def generate_prediction
      return I18n.t('eightball.empty').sample if command_parameters.blank?

      answers = I18n.t('.eightball.replies')
      digest = Digest::SHA1.hexdigest(command_parameters).to_i(16) - Date.today.to_time.to_i.div(100) - user.id
      answer_id = digest.divmod(answers.count)[1]
      answers[answer_id]
    end

    def enable
      chat.update(eightball: true)
      ok
    end

    def disable
      chat.update(eightball: false)
      ok
    end
  end
end
