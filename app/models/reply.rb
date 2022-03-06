# frozen_string_literal: true

class Reply < ApplicationRecord
  belongs_to :pair
  belongs_to :word, optional: true

  scope :chat, ->(id) { where(chat_id: id) }
end
