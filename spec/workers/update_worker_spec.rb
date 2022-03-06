# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateWorker, type: :worker do
  let(:update) { JSON.parse(FactoryBot.build(:tg_update).to_json) }

  it 'enqueues a worker' do
    expect { described_class.perform_async(update) }
      .to change(described_class.jobs, :size).by(1)
  end

  it 'sends update to UpdateProcessor' do
    expect(UpdateProcessor).to receive_message_chain(:call)
    described_class.new.perform(update)
  end
end
