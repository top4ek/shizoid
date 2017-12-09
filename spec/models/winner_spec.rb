require 'rails_helper'

RSpec.describe Winner, type: :model do
  let(:winner) { FactoryBot.create :winner }
  let(:old_winner) { FactoryBot.create :old_winner }
  let(:chat) { FactoryBot.create :chat }
  let(:chat2) { FactoryBot.create :chat }

  it 'has valid factory' do
    expect(winner).to be_valid
  end

  before :each do
    Shizoid::Redis.connection.del("winner_stats_#{chat.id}")
    Shizoid::Redis.connection.del("winner_stats_#{chat2.id}")
  end

  describe 'updates statistics' do
    it 'for one user in one chat' do
      Winner.update_stats(chat.id, chat.id, 4)
      stats = Winner.current_stats(chat.id)
      id = chat.id.to_s
      expect(stats[id]).to eq 4
      Winner.update_stats(chat.id, chat.id, 5)
      stats = Winner.current_stats(chat.id)
      expect(stats[id]).to eq 9
    end

    it 'for two users in one chat' do
      Winner.update_stats(chat.id, 1, 4)
      Winner.update_stats(chat.id, 2, 5)
      stats = Winner.current_stats(chat.id)
      id = chat.id.to_s
      expect(stats['1']).to eq 4
      expect(stats['2']).to eq 5
    end

    it 'for two users in two chats' do
      Winner.update_stats(chat.id, 2, 4)
      Winner.update_stats(chat2.id, 1, 5)
      id = chat.id.to_s
      id2 = chat2.id.to_s

      stats = Winner.current_stats(chat.id)
      expect(stats['2']).to eq 4
      stats = Winner.current_stats(chat2.id)
      expect(stats['1']).to eq 5
    end
  end

  it 'returns nil when no statistics' do
    expect(Winner.gamble(chat.id)).to eq nil
  end

  it 'returns winner' do
    Winner.update_stats(chat.id, chat.id, 5)
    expect(Winner.gamble(chat.id)).to eq chat.id
  end

  it 'deletes winners older than 365 days' do
    chat_id = old_winner.chat_id
    FactoryBot.create :yesterday_winner, { chat_id: chat_id }
    FactoryBot.create :winner, { chat_id: chat_id }
    expect{Winner.gamble(chat_id)}.to change{Winner.count}.by -1
  end

  it 'returns stats' do
    chat_id = old_winner.chat_id
    FactoryBot.create :yesterday_winner, { chat_id: chat_id, user_id: 123 }
    FactoryBot.create :winner, { chat_id: chat_id, user_id: 123 }
    stats = Winner.stats(chat_id)
    expect(stats[123]).to eq 2
  end
end
