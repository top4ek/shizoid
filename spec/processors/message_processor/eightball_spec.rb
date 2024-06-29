# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageProcessor::Eightball, type: :processor do
  let(:user)            { create :user }
  let(:chat)            { create :chat, eightball: true }
  let(:disabled_chat)   { create :chat, eightball: false }

  let(:message_params)  { { chat: { id: chat.telegram_id }, from: { id: user.id } } }
  let(:eightball)       { build :tg_message, :command_eightball, message_params }
  let(:ping)            { build :tg_message, :command_ping, message_params }
  let(:text)            { build :tg_message, message_params }
  let(:picture)         { build :tg_message, message_params.merge(text: nil) }

  let(:empty_command)   { build :tg_message, :command_empty_eightball, message_params }
  let(:disable_command) do
    build :tg_message, :command_empty_eightball, message_params.merge!(text: '/eightball disable')
  end
  let(:off_command) { build :tg_message, :command_empty_eightball, message_params.merge!(text: '/eightball off') }
  let(:enable_command) do
    build :tg_message, :command_empty_eightball,
          message_params.merge!(chat: { id: disabled_chat.telegram_id },
                                text: '/eightball enable')
  end
  let(:on_command) do
    build :tg_message, :command_empty_eightball,
          message_params.merge!(chat: { id: disabled_chat.telegram_id },
                                text: '/eightball on')
  end

  it 'has message model trait' do
    text_starts_with = eightball.text.starts_with? '/eightball'
    expect(text_starts_with).to be true
  end

  describe '#responds?' do
    it 'non eightball command' do
      expect(described_class.new(ping).responds?).to be false
    end

    it 'empty text' do
      expect(described_class.new(picture).responds?).to be false
    end

    it 'non command' do
      expect(described_class.new(text).responds?).to be false
    end
  end

  describe 'replies with' do
    it 'prediction' do
      result = described_class.new(eightball).process
      expect(I18n.t('.eightball.replies')).to include result[:send_message][:text]
    end

    it 'smth on empty command' do
      result = described_class.new(empty_command).process
      expect(I18n.t('.eightball.empty')).to include result[:send_message][:text]
    end
  end

  describe 'automatic triggering' do
    describe 'responds ok message' do
      %i[enable_command on_command disable_command off_command].each do |command|
        it command do
          result = described_class.new(send(command)).process
          expect(I18n.t('.ok')).to include result[:send_message][:text]
        end
      end
    end

    %i[enable_command on_command].each do |command|
      describe "with #{command}" do
        it 'enables' do
          expect do
            described_class.new(send(command)).process
            disabled_chat.reload
          end.to change(disabled_chat, :eightball).from(false).to(true)
        end
      end
    end

    %i[disable_command off_command].each do |command|
      describe 'disables with' do
        it command do
          expect do
            described_class.new(send(command)).process
            chat.reload
          end.to change(chat, :eightball).from(true).to(false)
        end
      end
    end
  end
end
