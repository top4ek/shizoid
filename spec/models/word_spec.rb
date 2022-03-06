# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Word, type: :model do
  let(:word)        { create :word }
  let(:words)       { create_list :word, 10 }
  let(:new_words)   { FFaker::LoremRU.words }
  let(:known_words) { words.pluck(:word) }
  let(:known_ids)   { words.pluck(:id) }

  it 'has valid factory' do
    expect(word).to be_valid
  end

  it '::to_words' do
    result = described_class.to_words(known_ids)
    expect(result).to eq known_words
  end

  it '::to_ids' do
    result = described_class.to_ids(known_words)
    expect(result).to eq known_ids
  end

  describe '::learn' do
    it 'learns new words' do
      expect { described_class.learn new_words }.to change(Word, :count).by new_words.size
    end

    it "doesn't add already known words" do
      described_class.learn new_words
      expect { described_class.learn new_words }.not_to change(Word, :count)
    end
  end
end
