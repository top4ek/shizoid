class Pair < ActiveRecord::Base
  has_many :replies
  belongs_to :chat

  belongs_to :first, class_name: 'Word'
  belongs_to :second, class_name: 'Word'

  def self.generate(message)
    generate_story(message, message.words, rand(2) + 1)
  end

  def self.generate_story(message, words, sentences)
    @word_ids = Word.where(word: words).pluck(:id)
    sentences.times.collect { generate_sentence(message) }.join(' ')
  end

  def self.learn(message)
    Word.learn message.words

    words = [ nil ]
    message.words.each do |word|
      words << word
      words << nil if Bot.configuration.punctuation['end_sentense'].include? word.last
    end
    words << nil unless words.last.nil?

    while words.any? do
      trigram = words.take(3)
      words.shift
      trigram_word_ids = trigram.map { |word| word.nil? ? nil : Word.find_by(word: word).id }
      pair = Pair.where(chat_id: message.chat.id, first_id: trigram_word_ids[0], second_id: trigram_word_ids[1]).first ||
        Pair.create(chat_id: message.chat.id, first_id: trigram_word_ids[0], second_id: trigram_word_ids[1])
      reply = pair.replies.where(word_id: trigram_word_ids[2]).first
      if reply.present?
        reply.increment! :count
      else
        Reply.create(pair_id: pair.id, word_id: trigram_word_ids[2])
      end
    end
  end

  private

  def self.generate_sentence(message)
    sentence = ''
    safety_counter = 50
    first_word = nil
    second_word  = @word_ids
    pair = nil
    while (pair = get_pair(chat_id: message.chat.id, first_id: first_word, second_id: second_word)) && safety_counter > 0 do
      safety_counter -= 1
      reply = pair.replies.order(count: :desc).limit(3).sample
      first_word = pair.second&.id
      second_word = reply.word&.id
      if sentence.empty?
        sentence = Unicode.capitalize("#{pair.second.word} ")
        @word_ids -= [pair.second.id]
      end
      reply.word.present? ? sentence += "#{reply.word.word} " : break
    end
    sentence.strip!
    sentence += Bot.configuration.punctuation['end_sentense'].split('').sample unless Bot.configuration.punctuation['end_sentense'].include? sentence.last
    sentence
  end

  def self.get_pair(chat_id:, first_id:, second_id:)
    Pair.includes(:replies).where(chat_id: chat_id, first_id: first_id, second_id: second_id).where("created_at < :latest", latest: 10.minutes.ago).limit(3).sample
  end

end
