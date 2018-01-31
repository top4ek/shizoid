class Reply < ActiveRecord::Base
  belongs_to :pair
  belongs_to :word, optional: true

  scope :chat, ->(id) { where(chat_id: id) }
end
