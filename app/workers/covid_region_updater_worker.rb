# frozen_string_literal: true

class CovidRegionUpdaterWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'updating'
  sidekiq_options retry: false

  def perform(region_id)
    CovidStat.update(region_id)
  end
end
