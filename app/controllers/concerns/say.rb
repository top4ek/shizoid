module Say
  def say(*args)
    return unless can_reply? && admin? && can_delete?
    respond_with :message, text: args.join(' '), parse_mode: :markdown
    bot.delete_message(chat_id: @chat.telegram_id, message_id: payload.message_id)
  end
end
