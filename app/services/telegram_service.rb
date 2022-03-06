# frozen_string_literal: true

module TelegramService
  class << self
    def bot_api
      return @bot_api if @bot_api.present?

      @bot_api = Telegram::Bot::Api.new(token)

      if webhook.present?
        @bot_api.set_webhook(url: "#{webhook}/#{token_secret}")
      else
        @bot_api.delete_webhook
      end
      @bot_api
    end

    def webhook
      Rails.configuration.secrets[:telegram][:webhook]
    end

    def token_secret
      @token_secret ||= token.split(':').last
    end

    def bot_id
      @bot_id ||= token.split(':').first.to_i
    end

    def token
      telegram_token = Rails.configuration.secrets[:telegram][:token]
      raise 'Telegram token is not configured' if telegram_token.blank?

      telegram_token
    end

    def start_polling
      bot_api
      Telegram::Bot::Client.run(token) do |bot|
        bot.listen { |update| UpdateWorker.perform_async(update) }
      end
    end

    delegate :send_message, :leave_chat, :delete_message, to: :bot_api
  end
end
