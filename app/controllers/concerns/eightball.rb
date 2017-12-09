module Eightball
  def eightball(*text)
    return unless can_reply?
    reply_text = t('shizoid.eightball.empty').sample
    return reply_with :message, text: reply_text if text.empty?
    case text.first
    when '—enable', '--enable'
      @chat.update(eightball: true)
      reply_text = ok
    when '—disable', '--disable'
      @chat.update(eightball: false)
      reply_text = ok
    else
      answers = t('shizoid.eightball.answers')
      message = payload.text.downcase
      digest = Digest::SHA1.hexdigest(message).to_i(16) - Date.today.to_time.to_i.div(100) - from.id
      answer_id = digest.divmod(answers.count)[1]
      send_typing_action
      reply_text = "#{answers[answer_id]} #{@chat.generate(@words)}"
    end
    reply_with :message, text: reply_text
  end
end
