# frozen_string_literal: true

module CasService
  class << self
    def banned?(telegram_id)
      body = Faraday.get(url(telegram_id)).body
      value = JSON.parse(body)
      ActiveModel::Type::Boolean.new.cast(value['ok'])
    rescue StandardError
      SentryService.capture_exception(exception)
      nil
    end

    private

    def url(telegram_id)
      "https://api.cas.chat/check?user_id=#{telegram_id}"
    end
  end
end
