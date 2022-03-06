# frozen_string_literal: true

class Winner < ApplicationRecord
  belongs_to :chat
  belongs_to :user

  before_save do
    self.date ||= Time.zone.today
  end
end
