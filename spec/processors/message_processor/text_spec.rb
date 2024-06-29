# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageProcessor::Text, type: :processor do
  subject(:result) { described_class.new(text).process }

  let(:user)           { create :user }
  let(:chat)           { create :chat, :disabled_random }
  let(:message_params) { { chat: { id: chat.telegram_id }, from: { id: user.id } } }
  let(:text)           { build :tg_message, message_params }

  before { PairUpdateWorker.new.perform(chat.id, text.text) }

  describe '#responds?' do
    let(:ping)    { build :tg_message, :command_ping, message_params }
    let(:picture) { build :tg_message, :picture, message_params }

    it 'diasbled chat' do
      chat.disable!
      expect(described_class.new(text).responds?).to be false
    end

    it 'command' do
      expect(described_class.new(ping).responds?).to be false
    end

    it 'empty text' do
      expect(described_class.new(picture).responds?).to be false
    end

    it 'text' do
      expect(described_class.new(text).responds?).to be true
    end
  end

  it '#background_task calls learn worker' do
    allow(PairUpdateWorker).to receive(:perform_async).with(chat.id, text.text)
    described_class.new(text)
    expect(PairUpdateWorker).to have_received(:perform_async)
  end

  describe 'sends message' do
    subject(:payload) { result[:send_message] }

    it 'to right chat' do
      expect(payload[:chat_id]).to eq chat.telegram_id
    end

    it 'with regular mode' do
      expect(payload[:parse_mode]).not_to be_present
    end
  end
end
