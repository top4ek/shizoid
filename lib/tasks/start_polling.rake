# frozen_string_literal: true

desc 'Start polling mode'
task start_polling: :environment do
  TelegramService.start_polling
end
