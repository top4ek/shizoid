# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IdleCheckWorker, type: :worker do
  let(:chat)           { create :chat, active_at: Time.current }
  let(:inactive_chat)  { create :chat, active_at: 20.days.ago }
  let(:participations) { create :participation, chat: chat }

  it 'enqueues a worker' do
    expect { described_class.perform_async }
      .to change(described_class.jobs, :size).by(1)
  end

  it 'sends results' do
    chat
    inactive_chat
    allow(SendPayloadWorker).to receive(:perform_async)
    described_class.new.perform
    expect(SendPayloadWorker).to have_received(:perform_async).once
  end
end
