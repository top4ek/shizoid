require 'rails_helper'

RSpec.describe Url, type: :model do
  let!(:url) { FactoryBot.create :url }
  let(:new_url) { FFaker::Internet.uri :http }

  it 'has valid factory' do
    expect(url).to be_valid
  end

  it 'returns true for old url' do
    expect(Url.seen?(url.url)).to eq true
  end

  it 'returns false on new url' do
    expect(Url.seen?(new_url)).to eq false
  end

  it 'saves new url' do
    expect{Url.seen?(new_url)}.to change{Url.count}.by(1)
  end

end
