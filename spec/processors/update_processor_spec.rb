# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateProcessor, type: :processor do
  subject(:call_result) { described_class.call(update) }

  let(:chat)   { FactoryBot.create :chat, telegram_id: update[:message][:chat][:id] }
  let(:update) { hashify_tg FactoryBot.build(:tg_update) }

  describe 'creates' do
    it 'chat' do
      expect { call_result }.to change(Chat, :count).by(1)
    end

    it 'user' do
      expect { call_result }.to change(User, :count).by(1)
    end

    it 'participation' do
      expect { call_result }.to change(Participation, :count).by(1)
    end
  end

  describe 'enqueues job' do
    it 'to MessageWorker' do
      chat
      expect { call_result }.to change(MessageWorker.jobs, :size).by(1)
    end

    # it 'sets queue limit to 1' do
    #   call_result
    #   expect(Sidekiq::Queue["chat_#{chat.id}"].limit).to eq 1
    # end
  end

  describe 'learns' do
    it 'chat' do
      expect(Chat).to receive_message_chain(:learn) { chat }
      call_result
    end

    it 'user' do
      expect(User).to receive_message_chain(:learn)
      call_result
    end

    it 'participation' do
      expect(Participation).to receive_message_chain(:learn)
      call_result
    end
  end
end
