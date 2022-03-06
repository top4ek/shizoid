# frozen_string_literal: true

class SendPayloadWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(command, parameters)
    TelegramService.send(command.to_sym, parameters)
  end
end
