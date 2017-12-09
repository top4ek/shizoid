module CoolStory
  def cool_story(*)
    return unless can_reply?
    reply_text = t('.').sample
    return reply_with :message, text: reply_text unless @chat.random_answer?(40)
    send_typing_action
    reply = @chat.generate_story
    return reply_with :message, text: reply if reply.present?
    reply_with :message, text: reply_text
  end
end
