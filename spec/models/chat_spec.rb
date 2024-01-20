# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Chat, type: :model do
  let!(:tg_chat)          { build :tg_chat }
  let(:chat)              { create :chat, telegram_id: tg_chat.id }
  let(:disabled_chat)     { create :chat, :disabled, telegram_id: tg_chat.id }
  let(:message)           { build :tg_message, chat: tg_chat }
  let(:migration_message) { build :tg_message, :with_migration, chat: tg_chat }

  it { is_expected.to have_many(:pairs) }
  it { is_expected.to have_many(:users).through(:participations) }
  it { is_expected.to have_many(:winners) }

  it 'has valid factory' do
    expect(chat).to be_valid
  end

  describe '#context' do
    subject(:method_call) { chat.context(new_ids) }

    let(:redis_key) { "chat_context/#{chat.id}" }
    let(:old_ids)   { %w[4 5 6 2] }

    after { RedisService.del(redis_key) }

    context 'when new ids absend' do
      let(:new_ids) { nil }

      context 'when context is empty' do
        it 'returns empty array' do
          expect(method_call).to eq []
        end
      end

      context 'when context is not empty' do
        before { RedisService.lpush(redis_key, old_ids) }

        it 'returns empty array' do
          expect(method_call).to match_array old_ids.map(&:to_i)
        end
      end
    end

    context 'when new ids present' do
      let(:new_ids) { %w[1 2 3 4] }

      context 'when context is empty' do
        before { RedisService.del(redis_key) }

        it 'adds new context' do
          method_call
          result = RedisService.lrange(redis_key, 0, 50)
          expect(result).to match_array new_ids
        end
      end

      context 'when context has smth' do
        before { RedisService.lpush(redis_key, old_ids) }

        it 'merges context' do
          method_call
          result = RedisService.lrange(redis_key, 0, 50)
          expect(result).to match_array(new_ids | old_ids)
        end
      end
    end
  end

  describe '#choose_winner!' do
    subject(:method_call) { chat.choose_winner! }

    let(:participations) { create_list :participation, 5, chat: }
    let(:candidates)     { chat.participations.scored.order(score: :desc).limit(3).map { |p| p.user.id } }

    before do
      participations
      candidates
    end

    it { expect(method_call).to be_a User }

    it 'creates new winner' do
      expect { method_call }.to change(Winner, :count).by(1)
    end

    it 'winner is one of candidates' do
      expect(method_call.id).to be_in candidates
      expect(Winner.last.user.id).to be_in candidates
    end
  end

  describe 'status' do
    it 'enabled?' do
      expect(chat.enabled?).not_to eq chat.active_at.nil?
    end

    it 'disabled?' do
      expect(chat.disabled?).to eq chat.active_at.nil?
    end

    it 'enable!' do
      expect(disabled_chat.disabled?).to eq true
      disabled_chat.enable!
      expect(disabled_chat.enabled?).to eq true
    end

    it 'disable!' do
      expect(chat.disabled?).to eq false
      chat.disable!
      expect(chat.enabled?).to eq false
    end
  end

  # describe '#answer_ramdomly?' do
  #   subject(:result) { chat.answer_randomly? }

  #   it 'true'
  #   do
  #     expect(Random).to receive_message_chain(:rand).and_return(100 )
  #     result
  #   end

  #   it 'false'
  # end

  # describe 'generate_reply' do
  #   let(:chat) { create :chat, telegram_id: tg_chat.id, random: 100 }
  #   it ''
  # end

  describe 'learn' do
    it 'creates chat' do
      expect { described_class.learn(message) }
        .to change(described_class, :count).by(1)
    end

    it 'migrates chat' do
      chat
      expect { described_class.learn(migration_message) }
        .not_to change(described_class, :count)
      chat.reload
      expect(chat.telegram_id).to eq migration_message.migrate_to_chat_id
    end

    it 'updates data' do
      chat
      expect { described_class.learn(message) }
        .not_to change(described_class, :count)
      chat.reload
      %i[title username first_name last_name].each do |f|
        expect(chat.send(f)).to eq message.chat.send(f)
      end
    end
  end
end
