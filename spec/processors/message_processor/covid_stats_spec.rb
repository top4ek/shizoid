# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageProcessor::CovidStats, type: :processor do
  subject(:process_method) { instance.process }

  let(:instance)       { described_class.new(message) }
  let(:user)           { create :user }
  let(:message_params) { { chat: { id: chat.telegram_id }, from: { id: user.id } } }
  let(:message)        { build :tg_message, message_params }
  let(:chat)           { create :chat, :disabled_random }
  let(:regions)        { CovidStat::FETCHABLE_REGIONS.sample(3) }
  let(:region)         { regions.sample }

  let(:stats) do
    regions.map do |r|
      [create(:covid_stat, region: r, sick: 1, healed: 1, died: 1, first: 1, second: 1, date: Time.zone.yesterday),
       create(:covid_stat, region: r, sick: 3, healed: 4, died: 5, first: 6, second: 7, date: Time.zone.today)]
    end.flatten
  end

  context 'when empty command' do
    let(:message) { build :tg_message, :command_covid_stats, message_params }

    describe 'responds with send_message' do
      subject(:send_message) { process_method[:send_message] }

      let(:expected_result) do
        results = CovidStat.day_stats(region: region)
        printable_results = CovidStat::STATISTICS_ATTRIBUTES.map do |a|
          current = results[:current].send(a) || '?'
          delta = "+#{results[:delta][a]}"
          [a, "#{current} (#{delta})"]
        end.to_h

        I18n.t('covid_stat.stats_html', region: I18n.t("covid_stat.regions.#{region}"),
                                        date: results[:date],
                                        sick: printable_results[:sick],
                                        healed: printable_results[:healed],
                                        died: printable_results[:died])
      end

      before { stats }

      it 'chat_id' do

        expect(send_message[:chat_id]).to eq chat.telegram_id
      end

      it 'reply_to_message_id' do
        expect(send_message[:reply_to_message_id]).to eq message.message_id
      end

      it 'parse_mode' do
        expect(send_message[:parse_mode]).to eq :html
      end

      context "when there's no region set" do
        let(:chat)   { create :chat, :disabled_random, covid_region: nil }
        let(:region) { 'ALL' }

        it 'shows latest overall data' do
          expect(send_message[:text]).to eq expected_result
        end
      end

      context 'when region is set to ALL' do
        let(:chat)   { create :chat, :disabled_random, covid_region: 'ALL' }
        let(:region) { 'ALL' }

        it 'shows latest overall data' do
          expect(send_message[:text]).to eq expected_result
        end
      end

      context 'when region is set to real region' do
        let(:chat) { create :chat, :disabled_random, covid_region: region }

        it 'shows latest region data' do
          expect(send_message[:text]).to eq expected_result
        end
      end
    end
  end

  context 'when available command' do
    let(:message) { build :tg_message, :command_covid_stats_available, message_params }

    describe 'responds with send_message' do
      subject(:send_message) { process_method[:send_message] }

      let(:participations) { create_list :participation, 15, chat: chat }

      it 'chat_id' do
        expect(send_message[:chat_id]).to eq chat.telegram_id
      end

      it 'reply_to_message_id' do
        expect(send_message[:reply_to_message_id]).to eq message.message_id
      end

      it 'parse_mode' do
        expect(send_message[:parse_mode]).to eq :html
      end

      it 'text' do
        list = I18n.t('covid_stat.regions').map do |key, name|
          I18n.t('covid_stat.region_item_html', key: key.to_s.rjust(4), name: name)
        end

        expect(send_message[:text]).to eq I18n.t('covid_stat.region_list_html', items: list.join("\n"))
      end
    end
  end

  context 'when enable command' do
    let(:chat) { create :chat, :disabled_random, covid_region: nil }

    shared_examples 'command enabler' do
      it 'changes covid_region attribute' do
        expect do
          process_method
          chat.reload
        end.to change(chat, :covid_region).to(region)
      end

      describe 'responds with send_message' do
        subject(:send_message) { process_method[:send_message] }

        it 'chat_id' do
          expect(send_message[:chat_id]).to eq chat.telegram_id
        end

        it 'reply_to_message_id' do
          expect(send_message[:reply_to_message_id]).to eq message.message_id
        end

        it 'text' do
          expect(I18n.t('.ok')).to include send_message[:text]
        end
      end
    end

    context 'without region' do
      let(:message) { build :tg_message, :command_covid_stats_enable, message_params.merge!(text: '/covid_stats enable') }
      let(:region)  { 'ALL' }

      it_behaves_like 'command enabler'
    end

    context 'with all region' do
      let(:message) { build :tg_message, :command_covid_stats_enable, message_params.merge!(text: '/covid_stats enable all') }
      let(:region)  { 'ALL' }

      it_behaves_like 'command enabler'
    end

    context 'with some region' do
      let(:message) do
        command = "/covid_stats enable #{region}"
        build :tg_message, :command_covid_stats_enable, message_params.merge!(text: command)
      end

      it_behaves_like 'command enabler'
    end
  end

  context 'when disable command' do
    let(:message) { build :tg_message, :command_covid_stats_disable, message_params }

    it 'changes covid_region attribute' do
      expect do
        process_method
        chat.reload
      end.to change(chat, :covid_region).to(nil)
    end

    describe 'responds with send_message' do
      subject(:send_message) { process_method[:send_message] }

      it 'chat_id' do
        expect(send_message[:chat_id]).to eq chat.telegram_id
      end

      it 'reply_to_message_id' do
        expect(send_message[:reply_to_message_id]).to eq message.message_id
      end

      it 'text' do
        expect(I18n.t('.ok')).to include send_message[:text]
      end
    end
  end
end
