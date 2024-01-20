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
