class Word < ApplicationRecord
  has_many :singles

  class << self
    def to_words(ids)
      words_relations = Word.where(id: ids).pluck(:id, :word).to_h
      ids.map { |id| words_relations[id] }
    end

    def to_ids(words)
      words_relations = Word.where(word: words).pluck(:word, :id).to_h
      words.map { |word| words_relations[word] }
    end

    def learn(words)
      return nil unless words&.compact.present?
      new_words = words - Word.where(word: words).pluck(:word)
      Word.create(new_words.uniq.map { |word| { word: word } })
    end
  end
end
