module Me
  def me(*text)
    return unless can_reply?
    reply = "<b>#{from.username || from.first_name || from.last_name}<b> "
    reply += text.any? ? text.join(' ') : t('.').sample
    respond_with :message, text: reply, parse_mode: :html
    bot.delete_message(chat_id: @chat.telegram_id, message_id: payload.message_id) if can_delete?
  end
end
