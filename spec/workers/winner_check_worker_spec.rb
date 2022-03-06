# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WinnerCheckWorker, type: :worker do
  let(:chat) { create :chat }

  it 'enqueues a worker' do
    expect { described_class.perform_async }
      .to change(described_class.jobs, :size).by(1)
  end

  it 'starts update' do
    allow(WinnerGambleWorker).to receive(:perform_async).with(chat.id)
    described_class.new.perform
    expect(WinnerGambleWorker).to have_received(:perform_async).once
  end
end
