# frozen_string_literal: true

class UpdateWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: false

  def perform(update)
    UpdateProcessor.call update
  end
end
