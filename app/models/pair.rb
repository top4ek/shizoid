# frozen_string_literal: true

class Pair < ApplicationRecord
  belongs_to :first, class_name: 'Word', optional: true
  belongs_to :second, class_name: 'Word', optional: true
  belongs_to :chat, optional: true
  belongs_to :data_bank, optional: true
  has_many :replies, dependent: :destroy

  validate :check_chat_and_bank

  def check_chat_and_bank
    # Only chat or databank allowed
    return unless chat.present? == data_bank.present?

    errors.add(:chat, :present)
    errors.add(:data_bank, :present)
  end

  class << self
    def learn(chat: nil, data_bank: nil, words:)
      raise 'Chat OR Databank must be specified' if chat.nil? == data_bank.nil?
      Word.learn(words)

      words_array = [nil]
      words.each do |word|
        words_array << word
        words_array << nil if Rails.application.secrets.end_sentence.include? word.chars.last
      end
      words_array << nil unless words_array.last.nil?

      words_ids = Word.to_ids(words_array)
      while words_ids.any?
        trigram = words_ids.take 3
        if trigram.first.nil? && trigram.third.nil? && trigram.size > 2
          words_ids.shift 3
          next
        end
        words_ids.shift
        pair_params = { chat: chat,
                        data_bank: data_bank,
                        first_id: trigram.first,
                        second_id: trigram.second }
        pair = Pair.includes(:replies).find_or_create_by!(pair_params)
        pair.replies.find_or_create_by(word_id: trigram.third).increment! :count
      end
    end

    def build_sentence(chat: self.chat, words: nil, words_ids: nil)
      raise 'words or words_ids must be specified' if words.present? == words_ids.present?

      words_ids = Word.to_ids(words) if words.present?
      sentence = []
      safety_counter = 50
      pair_params = { chat: chat, first_id: nil, second_id: words_ids }

      while (pair = fetch_pair(pair_params)) && (sentence.size < safety_counter) do
        replies = pair.replies.order(count: :desc)
        replies_pool = 3 + replies.size / 2
        reply = replies.limit(replies_pool).sample
        pair_params = { chat: chat, first_id: pair.second_id, second_id: reply&.word_id }
        sentence << pair.second_id if sentence.empty?
        reply&.word_id.nil? ? break : sentence << reply.word_id
      end
      Word.to_words(sentence).join(' ').capitalize
    end

    private

    def fetch_pair(options)
      if options[:chat].data_bank_ids.any?
        chat_ids = [options[:chat].id, nil]
        databank_ids = [options[:chat].data_bank_ids, nil].flatten
      else
        chat_ids = options[:chat].id
        databank_ids = nil
      end

      Pair.includes(:replies)
          .order(Arel.sql('RANDOM()'))
          .where(chat_id: chat_ids,
                 data_bank_id: databank_ids,
                 first_id: options[:first_id],
                 second_id: options[:second_id]).first
    end
  end
end
