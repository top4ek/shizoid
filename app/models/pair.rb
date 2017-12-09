class Pair < ApplicationRecord
  belongs_to :first, class_name: 'Word', optional: true
  belongs_to :second, class_name: 'Word', optional: true
  belongs_to :chat, optional: true
  belongs_to :data_bank, optional: true
  has_many :replies, dependent: :destroy

  validate :check_chat_and_bank

  def check_chat_and_bank
    return false if self.id.present? == self.data_bank_id.present?
  end

  class << self
    def generate_story(chat)
      10.times.collect { build_sentence(chat, chat.context) }.uniq.join(' ')
    end

    def generate(chat:, words:)
      words_ids = Word.to_ids(words)
      build_sentence(chat, words_ids) || build_sentence(chat, chat.context)
    end

    def learn(chat_id: nil, data_bank_id: nil, words:)
      raise 'Chat OR Databank must be specified' if chat_id.nil? == data_bank_id.nil?
      Word.learn(words)

      words_array = [ nil ]
      words.each do |word|
        words_array << word
        words_array << nil if Rails.application.secrets.punctuation[:end_sentense].include? word.chars.last
      end
      words_array << nil unless words_array.last.nil?

      words_ids = Word.to_ids(words_array)
      while words_ids.any?
        trigram = words_ids.take 3
        if trigram.first.nil? && trigram.third.nil? && trigram.size > 2
          words_ids.shift(3)
          next
        end
        words_ids.shift
        pair_params = { chat_id: chat_id, data_bank_id: data_bank_id, first_id: trigram.first, second_id: trigram.second }
        pair = Pair.includes(:replies).find_or_create_by!(pair_params)
        reply = pair.replies.find_or_create_by(word_id: trigram.third).increment! :count
      end
    end

    private

    def build_sentence(chat, words_ids)
      sentence = []
      safety_counter = 50
      pair_params = { chat: chat, first_id: nil, second_id: words_ids }

      while (pair = fetch(pair_params)) && (sentence.size < safety_counter) do
        replies = pair.replies.order(count: :desc)
        replies_pool = 3 + replies.size / 2
        reply = replies.limit(replies_pool).sample
        pair_params = { chat: chat, first_id: pair.second_id, second_id: reply&.word_id }
        sentence << pair.second_id if sentence.empty?
        reply&.word_id.nil? ? break : sentence << reply.word_id
      end
      Word.to_words(sentence).join(' ').capitalize
    end

    def fetch(chat:, first_id:, second_id:)
      if chat.data_bank_ids.any?
        chat_ids = [ chat.id, nil ]
        databank_ids = [ chat.data_bank_ids, nil ].flatten
      else
        chat_ids = chat.id
        data_bank_ids = nil
      end
      Pair.includes(:replies).where(chat_id: chat_ids, data_bank_id: databank_ids, first_id: first_id, second_id: second_id).sample
    end
  end
end
