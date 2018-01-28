module Locale
  def locale(*args)
    return unless can_reply?
    reply_text = t('.reply',
                   available: I18n.available_locales.to_sentence,
                   current: t('.current'))
    parameter = args.first
    if parameter.present?
      if parameter.in? I18n.available_locales.map(&:to_s)
        @chat.update(locale: parameter)
        I18n.locale = parameter
        reply_text = t('.current')
      else
        reply_text = nok
      end
    end
    reply_with :message, text: reply_text, parse_mode: :markdown
  end
end
