module Ids
  def ids(*)
    return unless can_reply?
    text = t('.ids', user: from.id, chat: @chat.telegram_id, type: @chat.kind)
    respond_with :message, text: text, parse_mode: :markdown
  end
end
