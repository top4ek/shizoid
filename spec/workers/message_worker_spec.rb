# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageWorker, type: :worker do
  let(:message) { hashify_tg FactoryBot.build :tg_message }

  it 'enqueues a worker' do
    expect { described_class.perform_async(message) }
      .to change(described_class.jobs, :size).by(1)
  end

  it 'runs MessageProcessor' do
    expect(MessageProcessor).to receive_message_chain(:call)
    described_class.new.perform(message)
  end
end
