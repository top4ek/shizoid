class Winner < ApplicationRecord
  belongs_to :chat

  class << self
    def update_stats(chat_id, user_id, count)
      chat_id = chat_id.to_s
      user_id = user_id.to_s
      stats = current_stats(chat_id)
      stats = { user_id => 0 } unless stats.present?
      stats[user_id] = 0 unless stats[user_id].present?
      stats[user_id] += count.to_i
      save_stats(chat_id, stats)
    end

    def current_stats(chat_id)
      JSON.parse(Shizoid::Redis.connection.get(redis_path(chat_id)) || '{}')
    end

    def stats(chat_id, user_id = nil)
      clean
      if user_id.present?
        {
          dates: Winner.where(chat_id: chat_id, user_id: user_id).order(created_at: :desc).limit(10).pluck(:created_at),
          count: Winner.where(chat_id: chat_id, user_id: user_id).count
        }
      else
        Winner.where(chat_id: chat_id).group(:user_id).order(count: :desc).limit(10).count(:user_id)
      end
    end

    def gambled?(chat_id)
      Winner.exists? chat_id: chat_id, created_at: Date.today
    end

    def gamble(chat_id)
      clean
      winner = Winner.find_by(chat_id: chat_id, created_at: Date.today)
      return winner.user_id if winner.present?
      stats = current_stats(chat_id)
      return nil unless stats.present?
      winner_id = stats.sort_by { |key, value| value }.reverse[0..2].sample.first
      Winner.create(chat_id: chat_id, user_id: winner_id, created_at: Date.today)
      drop_stats(chat_id)
      winner_id.to_i
    end

    private

    def redis_path(chat_id)
      "winner_stats_#{chat_id}"
    end

    def clean
      Winner.where('created_at < ?', 365.days.ago).delete_all
    end

    def drop_stats(chat_id)
      Shizoid::Redis.connection.del(redis_path(chat_id))
    end

    def save_stats(chat_id, stats)
      Shizoid::Redis.connection.set(redis_path(chat_id), stats.to_json)
    end
  end
end
