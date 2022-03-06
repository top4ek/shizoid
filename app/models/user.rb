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

  def self.learn(message)
    user = User.find_by(id: message.from.id) || User.new(id: message.from.id)
    user.update(message.from.to_h.slice(:username, :first_name, :last_name))
    user
  end
end
