# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CovidRegionUpdaterWorker, type: :worker do
  let(:region_id) { CovidStat::FETCHABLE_REGIONS.sample }

  it 'enqueues a worker' do
    expect { described_class.perform_async(region_id) }
      .to change(described_class.jobs, :size).by(1)
  end

  it 'sends update to UpdateProcessor' do
    allow(CovidStat).to receive(:update).with(region_id)
    described_class.new.perform(region_id)
    expect(CovidStat).to have_received(:update)
  end
end
