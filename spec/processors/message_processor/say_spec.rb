# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageProcessor::Say, type: :processor do
  subject(:result) { described_class.new(say).process }

  let(:user)           { create :user }
  let(:bot_owner)      { create :user, :bot_owner }
  let(:chat)           { create :chat }
  let(:message_params) { { chat: { id: chat.telegram_id }, from: { id: bot_owner.id } } }
  let(:say)            { build :tg_message, :command_say, message_params }
  let(:reply_say)      { build :tg_message, :reply, :command_say, message_params }
  let(:ping)           { build :tg_message, :command_ping, message_params }
  let(:text)           { build :tg_message, message_params }
  let(:picture)        { build :tg_message, :picture, message_params }

  it 'has message model trait' do
    text_starts_with = say.text.starts_with? '/say '
    expect(text_starts_with).to be true
  end

  describe '#responds?' do
    it 'diasbled chat' do
      chat.disable!
      expect(described_class.new(say).responds?).to be false
    end

    it 'non /say command' do
      expect(described_class.new(ping).responds?).to be false
    end

    it 'empty text' do
      expect(described_class.new(picture).responds?).to be false
    end

    it 'non command' do
      expect(described_class.new(text).responds?).to be false
    end
  end

  describe 'say without reply' do
    subject(:result) { described_class.new(say).process }

    it 'just answers' do
      expect(result[:send_message][:reply_to_message_id]).to be_nil
    end
  end

  describe 'say with reply' do
    subject(:result) { described_class.new(reply_say).process }

    describe 'deletes' do
      it 'message at right chat' do
        expect(result[:delete_message][:chat_id]).to eq chat.telegram_id
      end

      it 'right message' do
        expect(result[:delete_message][:message_id]).to eq reply_say.message_id
      end
    end

    describe 'sends message' do
      it 'to right chat' do
        expect(result[:send_message][:chat_id]).to eq chat.telegram_id
      end

      it 'with regular mode' do
        expect(result[:send_message][:parse_mode]).not_to be_present
      end

      it 'replies to the same message' do
        expect(result[:send_message][:reply_to_message_id]).to eq reply_say.reply_to_message.message_id
      end

      it 'with right text' do
        text = reply_say.text.split(' ')[1..-1].join(' ')
        expect(result[:send_message][:text]).to eq text
      end
    end
  end
end
