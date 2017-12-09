require 'rails_helper'

RSpec.describe Word, type: :model do
  let(:word) { FactoryBot.create :word }
  let(:words) { FFaker::Lorem.paragraph.split(' ').uniq }

  it 'has valid factory' do
    expect(word).to be_valid
  end

  before :each do
    Word.learn(words)
  end

  describe '#learn' do
    it "doesn't learns if no words specified" do
      expect(Word.learn(nil)).to eq nil
      expect(Word.learn([])).to eq nil
      expect(Word.learn([nil, nil])).to eq nil
      expect(Word.all.count).to eq words.count
    end

    it 'learns new words' do
      expect(Word.all.size).to eq words.count
    end

    it "doesn't learns old words" do
      3.times { Word.learn(words) }
      expect(Word.all.count).to eq words.count
    end
  end

  describe '#to_ids' do
    it 'returns ids' do
      words_relations = Word.where(word: words).pluck(:word, :id).to_h
      result = words.map { |word| words_relations[word] }
      expect(result).to eq Word.to_ids(words)
    end

    it 'returns nulls' do
      words << nil
      words.unshift nil
      result = Word.to_ids(words).select{|w| w.nil? }.count
      expect(result).to eq 2
    end
  end

  describe '#to_words' do
    it 'returns words' do
      ids = Word.to_ids(words)
      words_relations = Word.where(id: ids).pluck(:id, :word).to_h
      result = ids.map { |id| words_relations[id] }
      expect(result).to eq Word.to_words(ids)
    end

    it 'returns nulls' do
      words << nil
      words.unshift nil
      ids = Word.to_ids(words)
      result = Word.to_words(ids).select{|w| w.nil? }.count
      expect(result).to eq 2
    end
  end
end
