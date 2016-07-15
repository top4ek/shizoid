class Word < ActiveRecord::Base
  has_many :chains

  def self.learn(words)
    new_words = words - Word.where(word: words).pluck(:word)
    Word.create(new_words.uniq.map { |word| { word: word } })
  end

end
