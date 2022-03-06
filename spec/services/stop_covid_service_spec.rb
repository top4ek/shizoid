# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StopCovidService do
  subject(:call) { described_class.get_data(region_id) }

  let(:region_id) { CovidStat::FETCHABLE_REGIONS.sample }
  let(:stub)      { webmocks(:stop_covid, :get_region_stats, region_id: region_id) }

  before { stub }

  it 'makes request' do
    call
    expect(stub[:mock]).to have_been_requested
  end

  it 'converts dates from json' do
    result = stub[:body].map { |r| r.except(:date).merge(date: Date.parse(r[:date])) }
    expect(call).to eq result
  end
end
