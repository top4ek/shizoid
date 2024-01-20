# frozen_string_literal: true

class User < ApplicationRecord
  has_many :participations, dependent: :destroy
  has_many :chats, through: :participations

  def to_s
    username || first_name || last_name
  end

  def to_link
    "<a href='tg://user?id=#{id}'>#{self}</a>"
  end

  def self.learn(tg_user)
    user = User.find_by(id: tg_user.id) || User.new(id: tg_user.id)
    user.update(tg_user.to_h.slice(:username, :first_name, :last_name, :is_bot))
    user.save!
    user
  end
end
