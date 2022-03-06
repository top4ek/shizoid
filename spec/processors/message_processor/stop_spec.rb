# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageProcessor::Stop, type: :processor do
  subject(:result) { described_class.new(owner_stop).process }

  let(:user)           { create :user }
  let(:owner)          { create :user, :bot_owner }
  let(:chat)           { create :chat, active_at: 1.day.ago }
  let(:message_params) { { chat: { id: chat.telegram_id }, from: { id: owner.id } } }
  let(:owner_stop)     { build :tg_message, :command_stop, message_params }
  let(:user_stop)      { build :tg_message, :command_stop, message_params.merge!(from: { id: user.id }) }

  let(:ping)           { build :tg_message, :command_ping, message_params }
  let(:text)           { build :tg_message, message_params }
  let(:picture)        { build :tg_message, :picture, message_params }

  it 'has message model trait' do
    text_starts_with = owner_stop.text.starts_with? '/stop'
    expect(text_starts_with).to eq true
  end

  describe '#responds?' do
    it 'diasbled chat' do
      expect(described_class.new(ping).responds?).to eq false
    end

    it 'non /stop command' do
      expect(described_class.new(ping).responds?).to eq false
    end

    it 'empty text' do
      expect(described_class.new(picture).responds?).to eq false
    end

    it 'non command' do
      expect(described_class.new(text).responds?).to eq false
    end
  end

  it "doesn't disable chat by regular user" do
    expect do
      described_class.new(user_stop).process
       chat.reload
    end.not_to change(chat.reload, :active_at)
  end

  it 'disables chat' do
    expect do
      result
      chat.reload
    end.to change(chat.reload, :active_at)
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
