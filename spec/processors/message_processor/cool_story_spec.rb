require 'rails_helper'

RSpec.describe MessageProcessor::CoolStory, type: :processor do
  subject(:send_message) { instance.process[:send_message] }

  let(:instance)       { described_class.new(message) }
  let(:user)           { create :user }
  let(:message_params) { { chat: { id: chat.telegram_id }, from: { id: user.id } } }
  let(:message)        { build :tg_message, :command_cool_story, message_params }
  let(:text)           { FFaker::Lorem.sentence }
  let(:chat)           { create :chat, :disabled_random }

  before do
    PairUpdateWorker.new.perform(chat.id, text)
    chat.context Word.to_ids(text.split)
  end

  describe 'answers by message' do
    it 'text' do
      expect(send_message[:text]).to eq text
    end

    it 'reply_to_message_id' do
      expect(send_message[:reply_to_message_id]).to eq message.message_id
    end

    it 'chat_id' do
      expect(send_message[:chat_id]).to eq chat.telegram_id
    end
  end
end
