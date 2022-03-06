require 'rails_helper'

RSpec.describe MessageProcessor::BinaryDice, type: :processor do
  subject(:process_method) { instance.process }

  let(:instance)       { described_class.new(message) }
  let(:user)           { create :user }
  let(:message_params) { { text: text, chat: { id: chat.telegram_id }, from: { id: user.id } } }
  let(:message)        { build :tg_message, message_params }
  let(:chat)           { create :chat, :disabled_random }

  describe 'message without achor' do
    let(:text) { FFaker::Lorem.sentence }

    it 'does nothing' do
      expect(process_method).to eq nil
    end
  end

  describe 'message with achor' do
    subject(:send_message) { process_method[:send_message] }

    let(:text) { "#{FFaker::Lorem.sentence} #{I18n.t('binary_dice.anchors').sample} #{FFaker::Lorem.sentence}?" }

    it 'chat_id' do
      expect(send_message[:chat_id]).to eq chat.telegram_id
    end

    it 'reply_to_message_id' do
      expect(send_message[:reply_to_message_id]).to eq message.message_id
    end

    it 'answers by one of the options' do
      expect(I18n.t('binary_dice.answers')).to include send_message[:text]
    end
  end
end
