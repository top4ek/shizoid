# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageProcessor::Ids, type: :processor do
  subject(:result) { described_class.new(ids).process }

  let(:user)           { create :user }
  let(:chat)           { create :chat }
  let(:message_params) { { chat: { id: chat.telegram_id }, from: { id: user.id } } }
  let(:ids)            { build :tg_message, :command_empty_gab, message_params.merge!(text: '/ids') }
  let(:ping)           { build :tg_message, :command_ping, message_params }
  let(:text)           { build :tg_message, message_params }
  let(:picture)        { build :tg_message, :picture, message_params }

  it 'has message model trait' do
    text_starts_with = ids.text.starts_with? '/ids'
    expect(text_starts_with).to be true
  end

  describe '#responds?' do
    it 'diasbled chat' do
      chat.disable!
      expect(described_class.new(ids).responds?).to be true
    end

    it 'non /ids command' do
      expect(described_class.new(ping).responds?).to be false
    end

    it 'empty text' do
      expect(described_class.new(picture).responds?).to be false
    end

    it 'non command' do
      expect(described_class.new(text).responds?).to be false
    end
  end

  it 'without text replies with current gab level' do
    expect(result[:send_message][:text]).to eq I18n.t('.ids', type: chat.kind, chat: chat.telegram_id, user: user.id)
  end
end
