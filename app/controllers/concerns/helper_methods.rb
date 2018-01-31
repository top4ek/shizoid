module HelperMethods
  def ok
    t('.ok').sample
  end

  def nok
    t('.nok').sample
  end

  def send_typing_action
    bot.send_chat_action(chat_id: @chat.telegram_id, action: :typing)
  end

  def new_member?
    payload.new_chat_members.present?
  end

  def anchors?
    text? && ((t('.anchors') & @words).any? || @words.include?("@#{bot.username.downcase}"))
  end

  def can_delete?
    begin
      result = bot.async(false) do
        bot.get_chat_member(chat_id: @chat.telegram_id,
                            user_id: bot_id)['result']['can_delete_messages']
      end
    rescue
      result = false
    end
    result
  end

  def bot_id
    @bot_id ||= Rails.application.secrets.telegram[:bot][:token].split(':').first.to_i
  end

  def reply_to_bot?
    payload&.reply_to_message&.from&.id == bot_id
  end

  def can_reply?
    admin? || @chat.active?
  end

  def question?
    text? && @text.last == '?'
  end

  def sticker?
    payload.sticker.present?
  end

  def document?
    payload.document.present?
  end

  def text?
    payload.text.present?
  end

  def reply?
    payload.reply_to_message.present?
  end

  def command?
    text? && payload.text.chars.first == '/'
  end

  def admin?
    Rails.application.secrets.admins.include? from.id
  end

  def private_admin?
    Rails.application.secrets.admins.include? @chat.telegram_id
  end
end
