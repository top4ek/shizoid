# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CovidStat, type: :model do
  let(:stat)    { create :covid_stat }
  let(:regions) { CovidStat::FETCHABLE_REGIONS.sample(3) }
  let(:region)  { regions.sample }
  let(:stub)    { webmocks(:stop_covid, :get_region_stats, region_id: region) }
  let(:chat)    { create :chat }

  describe 'validations with' do
    let(:virtual_region) { build(:covid_stat, region: described_class::VIRTUAL_REGIONS.sample) }

    it 'valid factory' do
      expect(stat).to be_valid
    end

    it 'virtual region' do
      expect(virtual_region).not_to be_valid
    end
  end

  describe ':day_stat' do
    let(:stats) do
      regions.map do |r|
        [create(:covid_stat, region: r, sick: 1, healed: 1, died: 1, first: 1, second: 1, date: Time.zone.yesterday),
         create(:covid_stat, region: r, sick: 3, healed: 4, died: 5, first: 6, second: 7, date: Time.zone.today)]
      end.flatten
    end

    describe 'shows current stats' do
      subject(:call_method) { described_class.day_stats(region: region) }

      before { stats }

      it 'date' do
        expect(call_method[:date]).to eq Time.zone.today
      end

      context 'when region set to ALL' do
        let(:region) { 'ALL' }

        it 'sick' do
          expect(call_method[:delta][:sick]).to eq 2 * regions.size
        end

        it 'healed' do
          expect(call_method[:delta][:healed]).to eq 3 * regions.size
        end

        it 'died' do
          expect(call_method[:delta][:died]).to eq 4 * regions.size
        end

        # it 'first' do
        #   expect(call_method[:delta][:first]).to eq 5 * regions.size
        # end

        # it 'second' do
        #   expect(call_method[:delta][:second]).to eq 6 * regions.size
        # end
      end

      context 'when region specified' do
        it 'sick' do
          expect(call_method[:delta][:sick]).to eq 2
        end

        it 'healed' do
          expect(call_method[:delta][:healed]).to eq 3
        end

        it 'died' do
          expect(call_method[:delta][:died]).to eq 4
        end

        # it 'first' do
        #   expect(call_method[:delta][:first]).to eq 5
        # end

        # it 'second' do
        #   expect(call_method[:delta][:second]).to eq 6
        # end
      end
    end
  end

  describe ':needs_update?' do
    subject(:call) { described_class.needs_update? }

    before do
      stub
      stub_const('CovidStat::FETCHABLE_REGIONS', [region])
    end

    it 'makes request' do
      call
      expect(stub[:mock]).to have_been_requested
    end

    it 'has new stats' do
      expect(call).to be_truthy
    end

    it 'has no new stats' do
      described_class.update(region)
      expect(call).to be_falsy
    end
  end

  describe ':update_all' do
    subject(:call) { described_class.update_all }

    it 'enqueues a worker for each region' do
      expect { call }
        .to change(CovidRegionUpdaterWorker.jobs, :size)
        .by(described_class::FETCHABLE_REGIONS.size)
    end
  end

  describe ':update' do
    subject(:call) { described_class.update region }

    before { stub }

    it 'makes request' do
      call
      expect(stub[:mock]).to have_been_requested
    end

    it 'creates new record' do
      expect { call }.to change(described_class, :count).by(30)
    end
  end
end
