namespace :cron do
  task clear_inactive: :environment do
    # Leave and clear inactive chats
    Chat.inactive.not_personal.each do |chat|
      chat.leave! if chat.created_at < 1.day.ago
      ChatDestroyer.perform_async(chat.id) if chat.created_at < 7.days.ago
    end

    # Leave active but silent chats for 14 days
    Chat.active.not_personal.where('active_at < ?', 14.days.ago).each do |chat|
      # Give few days before destroy data
      chat.update(created_at: Time.now)
      chat.leave!
    end

    # Say smth in active but silent chats for 7 days
    bot = Telegram::Bot::Client.new(Rails.application.secrets.telegram[:bot][:token])
    Chat.active.not_personal.where('active_at < ?', 7.days.ago).each do |chat|
      reply = I18n.t('tasks.clear_inactive.anybody_here', locale: chat.locale).sample
      bot.send_message(chat_id: chat.telegram_id, text: reply)
    end
  end
end
