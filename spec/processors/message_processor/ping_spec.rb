# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageProcessor::Ping, type: :processor do
  subject(:result) { described_class.new(ping).process }

  let(:user)           { create :user }
  let(:chat)           { create :chat }
  let(:message_params) { { chat: { id: chat.telegram_id }, from: { id: user.id } } }
  let(:ping)           { build :tg_message, :command_ping, message_params }
  let(:me)             { build :tg_message, :command_me, message_params }
  let(:text)           { build :tg_message, message_params }
  let(:picture)        { build :tg_message, :picture, message_params }

  it 'has message model trait' do
    text_starts_with = ping.text.starts_with? '/ping'
    expect(text_starts_with).to be true
  end

  describe '#responds?' do
    it 'diasbled chat' do
      chat.disable!
      expect(described_class.new(ping).responds?).to be false
    end

    it 'non /ping command' do
      expect(described_class.new(me).responds?).to be false
    end

    it 'empty text' do
      expect(described_class.new(picture).responds?).to be false
    end

    it 'non command' do
      expect(described_class.new(text).responds?).to be false
    end
  end

  describe 'pongs' do
    it 'to right chat' do
      expect(result[:send_message][:chat_id]).to eq chat.telegram_id
    end

    it 'with regular mode' do
      expect(result[:send_message][:parse_mode]).not_to be_present
    end

    it 'replies to the message' do
      expect(result[:send_message][:reply_to_message_id]).to eq ping.message_id
    end

    it 'with right text' do
      expect(I18n.t('.ping')).to include result[:send_message][:text]
    end
  end
end
