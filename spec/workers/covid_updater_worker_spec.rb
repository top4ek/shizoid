# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CovidUpdaterWorker, type: :worker do
  let(:region_id) { CovidStat::FETCHABLE_REGIONS.sample }
  let(:stub)      { webmocks(:stop_covid, :get_region_stats, region_id: region_id) }

  before do
    stub
    stub_const('CovidStat::FETCHABLE_REGIONS', [region_id])
  end

  it 'enqueues a worker' do
    expect { described_class.perform_async(region_id) }
      .to change(described_class.jobs, :size).by(1)
  end

  it 'checks if update available' do
    allow(CovidStat).to receive(:needs_update?)
    described_class.new.perform
    expect(CovidStat).to have_received(:needs_update?)
  end

  it 'starts update' do
    allow(CovidStat).to receive(:update_all)
    described_class.new.perform
    expect(CovidStat).to have_received(:update_all)
  end

  it "doesn't start update" do
    allow(CovidStat).to receive(:needs_update?).and_return(false)
    allow(CovidStat).to receive(:update_all)
    described_class.new.perform
    expect(CovidStat).not_to have_received(:update_all)
  end
end
