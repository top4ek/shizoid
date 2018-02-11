namespace :cron do
  task clear_inactive: :environment do
    Chat.inactive.each do |chat|
      chat.leave! if chat.created_at > 1.day.ago
      ChatDestroyer.perform_async(chat.id) if chat.created_at > 7.days.ago
    end
  end
end
