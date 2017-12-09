module Locale
  def locale(*args)
    return unless can_reply?
    reply_text = t('.status.locale')
    if args.first == '—set' || args.first == '--set'
      if I18n.available_locales.map(&:to_s).include? args.second
        @chat.update(locale: args.second)
        I18n.locale = args.second
        reply_text = t('.status.locale')
      else
        reply_text = nok
      end
    end
    respond_with :message, text: reply_text
  end
end
