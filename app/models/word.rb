# frozen_string_literal: true

class Word < ApplicationRecord
  class << self
    def to_words(ids)
      words_relations = Word.where(id: ids.uniq).pluck(:id, :word).to_h
      ids.map { |id| words_relations[id] }
    end

    def to_ids(words)
      words_relations = Word.where(word: words.uniq).pluck(:word, :id).to_h
      words.map { |word| words_relations[word] }
    end

    def learn(words)
      words = words&.uniq&.compact
      return nil if words.blank?

      new_words = words - Word.where(word: words).pluck(:word)
      return nil if new_words.blank?

      words_array = new_words.uniq.map { |word| { word: } }
      Word.insert_all(words_array)
    end
  end
end
