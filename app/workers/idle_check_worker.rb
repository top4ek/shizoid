# frozen_string_literal: true

class IdleCheckWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    Chat.active.where('active_at > ?', 7.days.ago).each do |c|
      c.update!(active_at: Time.current)
      SendPayloadWorker.perform_async(:send_message,
                                      text: I18n.t('idle').sample,
                                      chat_id: c.telegram_id)
    end
  end
end
