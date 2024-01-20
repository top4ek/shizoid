# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WinnerGambleWorker, type: :worker do
  let(:chat)           { create :chat }
  let(:participations) { create :participation, chat: }

  it 'enqueues a worker' do
    expect { described_class.perform_async }
      .to change(described_class.jobs, :size).by(1)
  end

  it 'sends results' do
    participations
    allow(SendPayloadWorker).to receive(:perform_async)
    described_class.new.perform(chat.id)
    expect(SendPayloadWorker).to have_received(:perform_async).once
  end
end
