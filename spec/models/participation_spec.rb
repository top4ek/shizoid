# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Participation, type: :model do
  let!(:tg_chat)      { build :tg_chat, type: 'supergroup' }
  let(:tg_user)       { build :tg_user }
  let(:chat)          { create :chat, telegram_id: tg_chat.id }
  let(:user)          { create :user, id: tg_user.id }
  let(:participation) { create :participation, user: user, chat: chat }
  let(:message)       { build :tg_message, chat: tg_chat, from: tg_user }
  let(:leave_message) { build :tg_message, chat: tg_chat, from: tg_user, left_chat_member: tg_user }

  it 'has valid factory' do
    expect(participation).to be_valid
  end

  describe 'ban' do
    subject(:method_call) { participation.ban }

    let(:user) { create :user, :casbanned }

    it 'updates participation status' do
      expect { method_call }.to change(participation, :left).from(false).to(true)
    end

    it 'sends ban command to tg' do
      allow(SendPayloadWorker).to receive(:perform_async)

      method_call

      expect(SendPayloadWorker).to have_received(:perform_async)
    end
  end

  describe 'ban_all' do
    subject(:method_call) { described_class.ban_all }

    let(:banned_user)           { create :user, :casbanned }
    let(:banned_participations) { create_list :participation, 5, user: banned_user }
    let(:participations)        { banned_participations.map { |p| create :participation, chat: p.chat } }

    before { participations }

    it "doesn't update other users participations" do
      expect do
        method_call
        participations.each(&:reload)
      end.not_to change { participations.map(&:left) }
    end

    it 'updates participation status' do
      expect do
        method_call
        banned_participations.each(&:reload)
      end.to change { banned_participations.map(&:left) }
        .from([false, false, false, false, false])
        .to([true, true, true, true, true])
    end
  end

  describe 'learn' do
    it 'creates participation' do
      chat
      user
      expect { described_class.learn(message) }.to change(described_class, :count).by(1)
      last = described_class.last
      expect(last.left?).to eq false
      expect(last.active_at).not_to be_nil
    end

    it 'updates participation' do
      chat
      user
      participation
      expect { described_class.learn(leave_message) }.not_to change(described_class, :count)
      expect(participation.reload.left?).to eq true
    end
  end
end
