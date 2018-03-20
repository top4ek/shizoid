class Participation < ApplicationRecord
  belongs_to :chat
  belongs_to :participant, class_name: 'Chat'
end
