# frozen_string_literal: true

class CovidUpdaterWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'updating'
  sidekiq_options retry: false

  def perform
    CovidStat.update_all if CovidStat.needs_update?
  end
end
