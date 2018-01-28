module Gab
  def gab(*args)
    return unless can_reply?
    reply_text = t('.level', chance: @chat.random)
    if args.first.present?
      percent = args.first.to_i
      if percent >= 0 && percent < 51
        @chat.update(random: percent)
        reply_text = "#{ok} #{t('.level', chance: @chat.random)}"
      else
        reply_text = t('.error')
      end
    end
    respond_with :message, text: reply_text, parse_mode: :markdown
  end
end
