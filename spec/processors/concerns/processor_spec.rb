# frozen_string_literal: true

require 'rails_helper'

module MessageProcessor
  class ProcessorConcernStub
    include Processor

    def process!
      true
    end
  end
end

RSpec.describe MessageProcessor::ProcessorConcernStub, type: :processor do
  subject(:instance) { described_class.new(active_command) }

  let(:participation)     { create :participation, user: user, chat: active_chat}
  let(:user)              { create :user }
  let(:active_chat)       { create :chat }
  let(:inactive_chat)     { create :chat, :disabled }
  let(:active_command)    { build :tg_message, :command_me, from: { id: user.id }, chat: { id: active_chat.telegram_id } }
  let(:inactive_command)  { build :tg_message, :command_me, chat: { id: inactive_chat.telegram_id } }
  let(:bot_owner_command) { build :tg_message, :command_me, :from_bot_owner, chat: { id: active_chat.telegram_id } }

  it 'reponds to active chat' do
    respond = instance.responds?
    expect(respond).to eq true
  end

  it "doesn't respond to inactive chat" do
    respond = described_class.new(inactive_command).responds?
    expect(respond).to eq false
  end

  it '#command?' do
    expect(instance.send(:command?)).to eq true
  end

  describe '#command' do
    context 'without username' do
      it 'returns bare command' do
        expect(instance.send(:command)).to eq 'me'
      end
    end

    context 'with username' do
      let(:active_command) { build :tg_message, :command_me_username, from: { id: user.id }, chat: { id: active_chat.telegram_id } }

      it 'returns bare command' do
        expect(instance.send(:command)).to eq 'me'
      end
    end
  end

  it '#text_without_command' do
    text = instance.text.split(' ')[1..].join(' ')
    expect(instance.send(:text_without_command)).to eq text
  end

  it '#chat' do
    expect(instance.send(:chat).id).to eq active_chat.id
  end

  it '#user' do
    expect(instance.send(:user).id).to eq user.id
  end

  it '#participation' do
    participation
    expect(instance.send(:participation).id).to eq participation.id
  end

  describe '#message_from_bot_owner?' do
    it do
      expect(instance.send(:message_from_bot_owner?)).to be_falsy
    end

    it do
      expect(described_class.new(bot_owner_command).send(:message_from_bot_owner?)).to be_truthy
    end
  end
end
