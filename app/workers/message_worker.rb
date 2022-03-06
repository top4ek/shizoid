# frozen_string_literal: true

class MessageWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(message)
    MessageProcessor.call message
  end
end
