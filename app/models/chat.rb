# frozen_string_literal: true

class Chat < ApplicationRecord
  has_many :participations, dependent: :destroy
  has_many :pairs, dependent: :destroy
  has_many :users, through: :participations
  has_many :winners, dependent: :destroy

  scope :inactive, -> { where(active_at: nil) }
  scope :active, -> { where.not(active_at: nil) }
  scope :not_personal, -> { where.not(kind: 'private') }
  scope :with_winners, -> { where.not(winner: nil) }

  def winner_enabled?
    winner.present?
  end

  def winner_disabled?
    !winner_enabled?
  end

  def current_winner
    winners.find_by(created_at: Time.zone.today)
  end

  def choose_winner!
    scores = participations.scored.order(score: :desc)
    winner = scores.limit(3).sample&.user
    return nil if winner.blank?

    winners.create(user: winner)
    scores.each { |p| p.update!(score: 0) }
    winner
  end

  def enabled?
    !disabled?
  end

  def disabled?
    active_at.nil?
  end

  def enable!
    update!(active_at: Time.current)
  end

  def disable!
    update!(active_at: nil)
  end

  def self.learn(message)
    chat_payload = message.chat
    chat = Chat.find_or_initialize_by(telegram_id: chat_payload.id)
    chat.telegram_id = message.migrate_to_chat_id if message.migrate_to_chat_id.present?
    chat.kind = chat_payload.type
    chat.update(chat_payload.to_h.slice(:title, :username, :first_name, :last_name))
    chat
  end

  def answer_randomly?(additional = 0)
    rand(100) < (random + additional)
  end

  def generate_reply(words)
    Pair.build_sentence(chat: self, words:) || Pair.build_sentence(chat: self, words_ids: context)
  end

  def generate_story
    context.collect { Pair.build_sentence(chat: self, words_ids: context) }.uniq.join('. ')
  end

  def context(ids = nil)
    size = Rails.configuration.secrets[:context_size]
    current = RedisService.lrange(redis_context_path, 0, size).map(&:to_i)
    return current.shuffle if ids.nil?

    uniq_ids = ids.uniq
    current -= uniq_ids
    current.unshift(*uniq_ids)
    RedisService.multi do |r|
      r.del(redis_context_path)
      r.lpush(redis_context_path, current.first(size))
    end
  end

  private

  def redis_context_path
    "chat_context/#{id}"
  end
end
