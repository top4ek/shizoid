# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pair, type: :model do
  let(:pair) { create :pair }
  # let(:words)       { create_list :word, 10 }
  # let(:new_words)   { FFaker::LoremRU.words }
  # let(:known_words) { words.pluck(:word) }
  # let(:known_ids)   { words.pluck(:id) }

  it 'has valid factory' do
    expect(pair).to be_valid
  end

  it { is_expected.to belong_to(:first).optional }
  it { is_expected.to belong_to(:second).optional }
  it { is_expected.to have_many(:replies) }

  describe 'validates pair belonging' do
    let(:chat)      { create :chat }
    let(:data_bank) { create :data_bank }

    context 'without chat and data bank' do
      subject(:result) { build :pair, chat: nil, data_bank: nil }

      it { expect(result).not_to be_valid }
    end

    context 'with chat and data bank' do
      subject(:result) { build :pair, chat:, data_bank: }

      it { expect(result).not_to be_valid }
    end

    context 'with chat' do
      subject(:result) { build :pair, chat:, data_bank: nil }

      it { expect(result).to be_valid }
    end

    context 'with data bank' do
      subject(:result) { build :pair, chat: nil, data_bank: }

      it { expect(result).to be_valid }
    end
  end

  describe '::build sentence' do
    subject(:result) { described_class.build_sentence chat:, words: }

    let(:chat)      { create :chat }
    let(:words)     { FFaker::Lorem.sentences.join(' ').split.uniq }
    let(:sentences) { words.join(' ').split('.').map { |s| "#{s.strip}." } }

    before { described_class.learn(chat:, words:) }

    it 'generates one of the old phrases' do
      expect(sentences).to include result
    end
  end

  describe '::learn' do
    subject(:result) { described_class.learn(chat:, words:) }

    let(:chat)            { create :chat }
    let(:words)           { FFaker::Lorem.sentences.join(' ').split.uniq }
    let(:sentences_count) { words.join.split('.').size }

    it 'learns new words' do
      new_words = words.uniq.size
      expect { result }.to change(Word, :count).by(new_words)
    end

    describe 'creates replies' do
      it 'correct count' do
        predictable_count = words.size + sentences_count
        expect { result }.to change(Reply, :count).by(predictable_count)
      end

      it 'correct replies' do
        result
        words.shift
        replies = Reply.all.map { |r| r.word&.word }.compact
        expect(words - replies).to eq []
      end
    end

    describe 'creates pairs' do
      it 'correct count' do
        predictable_count = words.size + sentences_count
        expect { result }.to change(described_class, :count).by(predictable_count)
      end

      it 'correct first words' do
        result
        first_words = described_class.all.map { |p| p.first&.word }.compact
        expect(first_words).to eq words
      end

      it 'correct second words' do
        result
        second_words = described_class.all.map { |p| p.second&.word }.compact
        expect(second_words).to eq words
      end
    end
  end

  # it '::to_words' do
  #   result = described_class.to_words(known_ids)
  #   expect(result).to eq known_words
  # end

  # it '::to_ids' do
  #   result = described_class.to_ids(known_words)
  #   expect(result).to eq known_ids
  # end

  # describe '::learn' do
  #   it 'learns new words' do
  #     expect { described_class.learn new_words }.to change(Word, :count).by new_words.size
  #   end

  #   it "doesn't add already known words" do
  #     described_class.learn new_words
  #     expect { described_class.learn new_words }.not_to change(Word, :count)
  #   end
  # end
end
