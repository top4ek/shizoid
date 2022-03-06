# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendPayloadWorker, type: :worker do
  let(:command) { 'send_message' }
  let(:params) { { chat_id: 1, text: 'test' }.to_json }

  it 'enqueues a worker' do
    expect { described_class.perform_async(command, params) }
      .to change(described_class.jobs, :size).by(1)
  end

  it 'runs TelegramService with required params' do
    expect(TelegramService).to receive_message_chain(:send).with(command.to_sym, params)
    described_class.new.perform(command, params)
  end
end
