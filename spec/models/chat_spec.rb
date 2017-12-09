require 'rails_helper'

RSpec.describe Chat, type: :model do
  let(:chat) { FactoryBot.create :chat }
  let(:payload) { FactoryBot.build :payload }

  it 'has valid factory' do
    expect(chat).to be_valid
  end

  # it 'creates chat' do
  #   Chat.learn payload
  #   binding.pry
  # end

  describe 'context' do
    let(:ids) { [0, 1, 2, 3, 4, 7, 8, 9] }
    let(:ids2) { [0, 1, 2, 5, 6, 7] }

    before :each do
      Shizoid::Redis.connection.del("chat_context/#{chat.id}")
    end

    it 'stores to redis' do
      chat.context ids
      expect(chat.context.sort).to eq ids.sort
    end

    it 'updates redis record' do
      chat.context ids
      chat.context ids2
      expect(chat.context.sort).to eq (ids | ids2).sort
    end

    it "stores =< #{Rails.application.secrets.context_size} ids" do
      test_size = Rails.application.secrets.context_size
      (1..test_size*2).each { |i| chat.context([i, i * 2]) }
      expect(chat.context.size).to eq test_size
    end
  end
end
