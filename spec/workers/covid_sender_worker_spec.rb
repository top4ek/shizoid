# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CovidSenderWorker, type: :worker do
  let(:region) { CovidStat::FETCHABLE_REGIONS.sample }
  let(:chat)   { create :chat, covid_region: region, covid_last_notification: Time.zone.yesterday }
  let(:stats) do
    [create(:covid_stat, region: region, date: Time.zone.yesterday),
     create(:covid_stat, region: region, date: Time.zone.today)]
  end

  it 'enqueues a worker' do
    expect { described_class.perform_async }.to change(described_class.jobs, :size).by(1)
  end

  it 'sends results' do
    chat
    stats
    allow(SendPayloadWorker).to receive(:perform_async)
    described_class.new.perform
    expect(SendPayloadWorker).to have_received(:perform_async).once
  end
end
