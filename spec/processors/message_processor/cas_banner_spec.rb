# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageProcessor::CasBanner, type: :processor do
  subject(:result) { described_class.new(message).process }

  let(:user)           { create :user }
  let(:chat)           { create :chat, :disabled_random }
  let(:message_params) { { chat: { id: chat.telegram_id }, from: { id: user.id } } }
  let(:message)        { build :tg_message, message_params }

  describe '#background_task' do
    let(:message)        { build :tg_message, :new_chat_members, message_params }
    let(:stubs)          { message.new_chat_members.map { |m| webmocks(:cas, :check, telegram_id: m.id, banned: true) } }
    let(:participations) { create_list(:participation, 2, chat: chat) }

    before do
      participations
      stubs
    end

    it 'makes requests' do
      result
      stubs.each { |s| expect(s[:mock]).to have_been_requested }
    end

    it "create's users" do
      user
      expect { result }.to change(User, :count).by(2)
    end
  end

  describe 'show' do
    let(:message) { build :tg_message, :command_cas, message_params }

    it 'without text replies with some stats' do
      chat.users << create(:user, :casbanned)
      create(:user, :casbanned)
      expect(result[:send_message][:text]).to eq "*Активен:* Нет\n*Всего:* 2%\n*В этом чате:* 1%\n"
    end
  end

  describe 'enable' do
    let(:message) { build :tg_message, :command_cas_enable, message_params }

    it 'changes casbanhammer_at to current date' do
      chat
      expect do
        result
        chat.reload
      end.to change(chat, :casbanhammer_at).from(nil)
    end
  end

  describe 'disable' do
    let(:message) { build :tg_message, :command_cas_disable, message_params }
    let(:chat)    { create :chat, :casbanhammer, :disabled_random }

    it 'changes casbanhammer_at to nil' do
      chat
      expect do
        result
        chat.reload
      end.to change(chat, :casbanhammer_at).to(nil)
    end
  end
end
