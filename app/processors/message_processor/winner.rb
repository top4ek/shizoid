# frozen_string_literal: true

module MessageProcessor
  class Winner
    include Processor
    include CommandParameters

    def responds?
      super && command == 'winner'
    end

    def process!
      response = case first_parameter
                 when 'enable', 'on'
                   enable
                 when 'disable', 'off'
                   disable
                 when 'current'
                   current_stats
                 else
                   previous_winner
                 end

      { send_message: { chat_id: chat.telegram_id,
                        reply_to_message_id: message.message_id,
                        parse_mode: :html,
                        text: response } }
    end

    private

    def current_stats
      top = chat.participations
                .includes(:user)
                .order(score: :desc)
                .limit(10)
                .each_with_index
                .map do |p, i|
                  I18n.t('winner.top_line_html', position: i + 1, user: p.user.to_s, score: p.score) if p.user.present?
                end.compact.join("\n")

      I18n.t('winner.current_html', top:)
    end

    def previous_winner
      winner = chat.winners.order(created_at: :desc)&.first&.user&.to_s

      if winner.present?
        top = chat.winners
                  .where('date > ?', 1.year.ago)
                  .group(:user)
                  .order(count: :desc)
                  .limit(10)
                  .count(:user)
                  .each_with_index
                  .map { |(user, wins), idx| I18n.t('winner.top_line_html', position: idx + 1, user: user.to_s, score: wins) }
                  .join("\n")

        I18n.t('winner.winner_html', top:, name: chat.winner, user: winner)
      else
        I18n.t('winner.no_one')
      end
    end

    def background_task
      return if command? || chat.disabled? || chat.winner_disabled?

      new_score = text_words&.size || 1
      participation.update!(score: participation.score + new_score)
    end

    def enable
      return nok if second_parameter.blank?

      chat.update!(winner: second_parameter)
      ok
    end

    def disable
      chat.update!(winner: nil)
      ok
    end
  end
end
