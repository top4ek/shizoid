# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageProcessor::Status, type: :processor do
  subject(:result) { described_class.new(status).process }

  let(:user)           { create :user }
  let(:chat)           { create :chat }
  let(:message_params) { { chat: { id: chat.telegram_id }, from: { id: user.id } } }
  let(:status)         { build :tg_message, :command_status, message_params }
  let(:me)             { build :tg_message, :command_me, message_params }
  let(:text)           { build :tg_message, message_params }
  let(:picture)        { build :tg_message, :picture, message_params }

  it 'has message model trait' do
    text_starts_with = status.text.starts_with? '/status'
    expect(text_starts_with).to eq true
  end

  describe '#responds?' do
    it 'diasbled chat' do
      chat.disable!
      expect(described_class.new(status).responds?).to eq false
    end

    it 'non /status command' do
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
      expect(result[:send_message][:reply_to_message_id]).to eq status.message_id
    end

    it 'with right text' do
      response = I18n.t('.status', version: Rails.configuration.secrets[:release],
                                   active: I18n.t(chat.enabled?.to_s),
                                   gab: chat.random,
                                   pairs: chat.pairs.size,
                                   databanks: I18n.t(chat.data_bank_ids.present?.to_s),
                                   cas_banner: I18n.t(chat.casbanhammer?.to_s),
                                   winner: chat.winner || t('.winner.disabled'))

      expect(response).to eq result[:send_message][:text]
    end
  end
end
