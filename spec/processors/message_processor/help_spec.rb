# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageProcessor::Help, type: :processor do
  subject(:result) { described_class.new(help).process }

  let(:user)           { create :user }
  let(:chat)           { create :chat }
  let(:message_params) { { chat: { id: chat.telegram_id }, from: { id: user.id } } }
  let(:help)           { build :tg_message, :command_help, message_params }
  let(:me)             { build :tg_message, :command_me, message_params }
  let(:text)           { build :tg_message, message_params }
  let(:picture)        { build :tg_message, :picture, message_params }

  it 'has message model trait' do
    text_starts_with = help.text.starts_with? '/help'
    expect(text_starts_with).to eq true
  end

  describe '#responds?' do
    it 'diasbled chat' do
      chat.disable!
      expect(described_class.new(help).responds?).to eq false
    end

    it 'non /help command' do
      expect(described_class.new(me).responds?).to eq false
    end

    it 'empty text' do
      expect(described_class.new(picture).responds?).to eq false
    end

    it 'non command' do
      expect(described_class.new(text).responds?).to eq false
    end
  end

  describe 'pongs' do
    it 'to right chat' do
      expect(result[:send_message][:chat_id]).to eq chat.telegram_id
    end

    it 'with markdown mode' do
      expect(result[:send_message][:parse_mode]).to eq :markdown
    end

    it 'replies to the message' do
      expect(result[:send_message][:reply_to_message_id]).to eq help.message_id
    end

    it 'with right text' do
      expect(result[:send_message][:text]).to eq I18n.t('.help')
    end
  end
end
