# frozen_string_literal: true

module MessageProcessor
  class Databank
    include Processor
    include CommandParameters

    def responds?
      super && command == 'databank'
    end

    def process!
      response = case first_parameter
                 when 'enable', 'on'
                   enable
                 when 'disable', 'off'
                   disable
                 else
                   show
                 end

      { send_message: { chat_id: chat.telegram_id,
                        text: response,
                        parse_mode: :html,
                        reply_to_message_id: message.message_id } }
    end

    private

    def enable
      databank_id = second_parameter.to_i
      return nok unless DataBank.exists?(id: databank_id) && !databank_id.in?(chat.data_bank_ids)

      chat.data_bank_ids << databank_id
      chat.save
      ok
    end

    def disable
      if second_parameter.blank?
        chat.update!(data_bank_ids: [])
        return ok
      end

      data_bank_id = second_parameter.to_i
      return nok unless data_bank_id.in?(chat.data_bank_ids)

      chat.data_bank_ids -= [data_bank_id]
      chat.save!
      ok
    end

    def show
      databanks = DataBank.pluck(:id, :name).to_h
      list = databanks.map { |id, name| I18n.t('.databank.list_line_html', id: id, name: name) }.join("\n")
      active = chat.data_bank_ids.present? ? chat.data_bank_ids.to_sentence : I18n.t('false')
      I18n.t('.databank.list_html', list: list, active: active)
    end
  end
end
