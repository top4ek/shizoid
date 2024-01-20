# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageProcessor::Me, type: :processor do
  subject(:result) { described_class.new(me).process }

  let(:user)           { create :user }
  let(:chat)           { create :chat }
  let(:message_params) { { chat: { id: chat.telegram_id }, from: { id: user.id } } }
  let(:me)             { build :tg_message, :command_me, message_params }
  let(:reply_me)       { build :tg_message, :reply, :command_me, message_params }
  let(:empty_me)       { build :tg_message, :command_empty_me, message_params }
  let(:ping)           { build :tg_message, :command_ping, message_params }
  let(:text)           { build :tg_message, message_params }
  let(:picture)        { build :tg_message, :picture, message_params }

  it 'has message model trait' do
    text_starts_with = me.text.starts_with? '/me '
    expect(text_starts_with).to eq true
  end

  describe '#responds?' do
    it 'diasbled chat' do
      chat.disable!
      expect(described_class.new(me).responds?).to eq false
    end

    it 'non /me command' do
      expect(described_class.new(ping).responds?).to eq false
    end

    it 'empty text' do
      expect(described_class.new(picture).responds?).to eq false
    end

    it 'non command' do
      expect(described_class.new(text).responds?).to eq false
    end
  end

  describe 'without text' do
    subject(:result) { described_class.new(empty_me).process }

    it 'replies with predefined answers' do
      replies = I18n.t('.me').map { |r| "<a href='tg://user?id=#{user.id}'>#{user.username}</a> #{r}" }
      expect(replies).to include result[:send_message][:text]
    end
  end

  describe 'me without reply' do
    subject(:result) { described_class.new(me).process }

    it "don't replies, just answers" do
      expect(result[:send_message][:reply_to_message_id]).to eq nil
    end
  end

  describe 'me with reply' do
    subject(:result) { described_class.new(reply_me).process }

    describe 'deletes' do
      it 'message at right chat' do
        expect(result[:delete_message][:chat_id]).to eq chat.telegram_id
      end

      it 'right message' do
        expect(result[:delete_message][:message_id]).to eq reply_me.message_id
      end
    end

    describe 'sends message' do
      it 'to right chat' do
        expect(result[:send_message][:chat_id]).to eq chat.telegram_id
      end

      it 'with html mode' do
        expect(result[:send_message][:parse_mode]).to eq :html
      end

      it 'replies to the same message' do
        expect(result[:send_message][:reply_to_message_id]).to eq reply_me.reply_to_message.message_id
      end

      it 'with right text' do
        text = reply_me.text.split(' ')[1..-1].join(' ')
        message = "<a href='tg://user?id=#{user.id}'>#{user.username}</a> #{text}"
        expect(result[:send_message][:text]).to eq message
      end
    end
  end
end
