# frozen_string_literal: true

class WinnerCheckWorker
  include Sidekiq::Worker

  def perform
    Chat.active.with_winners.reject(&:current_winner).each { |c| WinnerGambleWorker.perform_async(c.id) }
  end
end
