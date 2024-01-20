# frozen_string_literal: true

class WinnerGambleWorker
  include Sidekiq::Worker

  def perform(chat_id)
    chat = Chat.find(chat_id)
    winner = chat.choose_winner!
    return if winner.nil?

    top = chat.winners
              .where('date > ?', 1.year.ago)
              .group(:user)
              .order(count: :desc)
              .limit(10)
              .count(:user)
              .each_with_index
              .map { |(user, wins), idx| I18n.t('winner.top_line_html', position: idx + 1, user: user.to_s, score: wins) }
              .join("\n")

    parameters = { text: I18n.t('winner.winner_html', top:, name: chat.winner, user: winner.to_link),
                   parse_mode: :html,
                   disable_notification: true,
                   chat_id: chat.telegram_id }
    SendPayloadWorker.perform_async(:send_message, parameters)
  end
end
