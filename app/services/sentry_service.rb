# frozen_string_literal: true

module SentryService
  class << self
    def capture_exception(exception)
      return unless configured?

      Sentry.capture_exception(exception)
    end

    private

    def configured?
      Rails.configuration.secrets[:sentry_dsn].present?
    end
  end
end
