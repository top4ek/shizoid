# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageProcessor::Start, type: :processor do
  subject(:result) { described_class.new(owner_start).process }

  let(:user)           { create :user }
  let(:owner)          { create :user, :bot_owner }
  let(:chat)           { create :chat, :disabled }
  let(:message_params) { { chat: { id: chat.telegram_id }, from: { id: owner.id } } }
  let(:owner_start)    { build :tg_message, :command_start, message_params }
  let(:user_start)     { build :tg_message, :command_start, message_params.merge!(from: { id: user.id }) }

  let(:ping)           { build :tg_message, :command_ping, message_params }
  let(:text)           { build :tg_message, message_params }
  let(:picture)        { build :tg_message, :picture, message_params }

  it 'has message model trait' do
    text_starts_with = owner_start.text.starts_with? '/start'
    expect(text_starts_with).to eq true
  end

  describe '#responds?' do
    it 'diasbled chat' do
      expect(described_class.new(ping).responds?).to eq false
    end

    it 'non /start command' do
      expect(described_class.new(ping).responds?).to eq false
    end

    it 'empty text' do
      expect(described_class.new(picture).responds?).to eq false
    end

    it 'non command' do
      expect(described_class.new(text).responds?).to eq false
    end
  end

  it "doesn't enable chat by regular user" do
    expect do
      described_class.new(user_start).process
      chat.reload
    end.not_to change(chat, :active_at)
  end

  it 'enables chat' do
    expect do
      result
      chat.reload
    end.to change(chat, :active_at).from(nil)
  end

  describe 'sends message' do
    it 'to right chat' do
      expect(result[:send_message][:chat_id]).to eq chat.telegram_id
    end

    it 'with regular mode' do
      expect(result[:send_message][:parse_mode]).not_to be_present
    end

    it 'replies ok' do
      expect(I18n.t('.ok')).to include result[:send_message][:text]
    end
  end
end
