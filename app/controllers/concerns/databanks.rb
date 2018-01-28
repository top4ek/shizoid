module Databanks
  def databank(*args)
    return unless can_reply?
    databank_id = args.second.to_i
    case args.first
    when 'enable', 'on'
      if DataBank.exists?(id: databank_id) && !@chat.data_bank_ids.include?(databank_id)
        @chat.data_bank_ids << databank_id
        @chat.save
        reply_text = ok
      else
        reply_text = nok
      end
    when 'disable', 'off'
      if @chat.data_bank_ids.include? databank_id
        @chat.data_bank_ids -= [ databank_id ]
        @chat.save
        reply_text = ok
      else
        reply_text = nok
      end
    else
      databanks = DataBank.pluck(:id, :name)
      list = databanks.map{|d| t('.databank.list_line_html', id: d.first, name: d.second) }.join("\n")
      active = @chat.data_bank_ids.present? ? @chat.data_bank_ids.to_sentence : t('false')
      reply_text = t('.databank.list_html', list: list, active: active)
    end
    respond_with :message, text: reply_text, parse_mode: :html
  end
end
