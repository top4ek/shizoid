module Bayanizator
  def bayanizator(*args)
    return unless can_reply?
    reply_text = nok
    case args.first
    when 'enable', 'on'
      @chat.update(bayan: true)
      reply_text = ok
    when 'disable', 'off'
      @chat.update(bayan: false)
      reply_text = ok
    else
      reply_text = t('.bayanizator.size', size: Url.all.size)
    end
    reply_with :message, text: reply_text
  end

  def bayan?
    return unless text? && @chat.bayan?
    urls = payload.entities.select { |entity| entity.type == 'url' }
                           .map { |entity| payload.text[entity.offset, entity.length] }
    return if urls.empty?
    urls.select { |url| Url.seen? url }.any?
  end
end
