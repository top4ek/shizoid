# frozen_string_literal: true

class User < ApplicationRecord
  has_many :participations, dependent: :destroy
  has_many :chats, through: :participations

  scope :casbanned, -> { where.not(casbanned_at: nil) }

  def to_s
    username || first_name || last_name
  end

  def to_link
    "<a href='tg://user?id=#{id}'>#{self}</a>"
  end

  def casban!
    update!(casbanned_at: Time.current)
  end

  def casbanned?
    casbanned_at.present?
  end

  def self.learn(tg_user)
    user = User.find_by(id: tg_user.id) || User.new(id: tg_user.id)
    user.update(tg_user.to_h.slice(:username, :first_name, :last_name, :is_bot))
    user.save!
    user
  end

  def update_casban
    return if casbanchecked_at.present? && casbanchecked_at < 1.week.since

    banned = CasService.banned?(id)
    return if banned.nil?

    self.casbanchecked_at = Time.current
    self.casbanned_at = banned ? Time.current : nil

    save!
    self
  end
end
