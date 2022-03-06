# frozen_string_literal: true

require 'sidekiq/api'

Sidekiq.configure_server do |config|
  config.redis = Rails.configuration.secrets[:sidekiq_redis]

  Sidekiq::Cron::Job.destroy_all!
  Dir[Rails.root.join('config/sidekiq_schedules/*.yml')].each do |f|
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(f)
  end
  # end
end

Sidekiq.configure_client do |config|
  config.redis = Rails.configuration.secrets[:sidekiq_redis]
end
