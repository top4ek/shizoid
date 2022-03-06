# frozen_string_literal: true

if Rails.configuration.secrets[:sentry_dsn].present?
  Sentry.init do |config|
    config.dsn = Rails.configuration.secrets[:sentry_dsn]
    config.release = Rails.configuration.secrets[:release]
  end
end
