# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageProcessor::Gab, type: :processor do
  subject(:result) { described_class.new(gab).process }

  let(:user)           { create :user }
  let(:chat)           { create :chat, :disabled_random }
  let(:message_params) { { chat: { id: chat.telegram_id }, from: { id: user.id } } }
  let(:wrong_gab)      { build :tg_message, :command_empty_gab, message_params.merge!(text: '/gab 100') }
  let(:gab)            { build :tg_message, :command_empty_gab, message_params.merge!(text: '/gab 25') }
  let(:empty_gab)      { build :tg_message, :command_empty_gab, message_params }
  let(:ping)           { build :tg_message, :command_ping, message_params }
  let(:text)           { build :tg_message, message_params }
  let(:picture)        { build :tg_message, :picture, message_params }

  it 'has message model trait' do
    text_starts_with = gab.text.starts_with? '/gab'
    expect(text_starts_with).to eq true
  end

  describe '#responds?' do
    it 'diasbled chat' do
      chat.disable!
      expect(described_class.new(gab).responds?).to eq false
    end

    it 'non /gab command' do
      expect(described_class.new(ping).responds?).to eq false
    end

    it 'empty text' do
      expect(described_class.new(picture).responds?).to eq false
    end

    it 'non command' do
      expect(described_class.new(text).responds?).to eq false
    end
  end

  it 'without text replies with current gab level' do
    result = described_class.new(empty_gab).process
    reply = I18n.t('.gab.level', chance: chat.random)
    expect(reply).to eq result[:send_message][:text]
  end

  describe 'with level specified' do
    subject(:result) { described_class.new(gab).process }

    it 'changes gab level' do
      expect do
        result
        chat.reload
      end.to change(chat, :random).to(25)
    end

    describe 'sends message' do
      it 'to right chat' do
        expect(result[:send_message][:chat_id]).to eq chat.telegram_id
      end

      it 'with html mode' do
        expect(result[:send_message][:parse_mode]).to eq :markdown
      end

      it 'replies to the same message' do
        expect(result[:send_message][:reply_to_message_id]).to eq gab.message_id
      end
    end
  end

  describe 'with wrong level specified' do
    subject(:result) { described_class.new(wrong_gab).process }

    it 'changes gab level' do
      expect do
        result
        chat.reload
      end.not_to change(chat, :random)
    end

    describe 'sends message' do
      it 'to right chat' do
        expect(result[:send_message][:chat_id]).to eq chat.telegram_id
      end

      it 'replies to the same message' do
        expect(result[:send_message][:reply_to_message_id]).to eq wrong_gab.message_id
      end
    end
  end
end
