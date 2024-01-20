# frozen_string_literal: true

class DataBank < ApplicationRecord
  has_many :pairs, dependent: :destroy

  class << self
    def update(filename:, id: nil, name: nil)
      databank = Databank.find_by(id:) || Databank.create(name:)
      databank.pairs.destroy
      words = File.read(filename, 'r').split(' ')
      Pair.learn(chat_id: nil, data_bank_id: databank.id, words:)
    end
  end
end
