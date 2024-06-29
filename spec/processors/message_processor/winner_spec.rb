# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageProcessor::Winner, type: :processor do
  subject(:process_method) { instance.process }

  let(:instance)       { described_class.new(message) }
  let(:user)           { create :user }
  let(:message_params) { { chat: { id: chat.telegram_id }, from: { id: user.id } } }
  let(:message)        { build :tg_message, message_params }
  let(:chat)           { create :chat, :disabled_random }
  let(:participation)  { create :participation, user:, chat: }

  before { participation }

  context 'when message received' do
    it 'increments participant score' do
      participation

      expect do
        process_method
        participation.reload
      end.to change(participation, :score).by(message.text.split.size)
    end

    it "doesn't repsond to text" do
      expect(process_method).to be_nil
    end
  end

  context 'when chat disabled' do
    let(:chat) { create :chat, :disabled }

    it "doesn't repsond to command" do
      expect(process_method).to be_nil
    end

    it "doesn't process background tasks" do
      expect do
        process_method
        participation.reload
      end.not_to change participation, :score
    end
  end

  context 'when empty command' do
    let(:message) { build :tg_message, :command_winner, message_params }

    describe 'responds with send_message' do
      subject(:send_message) { process_method[:send_message] }

      let(:winners) { create_list :winner, 15, chat: }

      it 'chat_id' do
        expect(send_message[:chat_id]).to eq chat.telegram_id
      end

      it 'reply_to_message_id' do
        expect(send_message[:reply_to_message_id]).to eq message.message_id
      end

      it 'parse_mode' do
        expect(send_message[:parse_mode]).to eq :html
      end

      it 'when there no winners yet' do
        expect(send_message[:text]).to eq I18n.t('winner.no_one')
      end

      context 'when winner exists' do
        let(:expected_result) do
          top = chat.winners
                    .where('date > ?', 1.year.ago)
                    .group(:user)
                    .order(count: :desc)
                    .limit(10)
                    .count(:user)
                    .each_with_index
                    .map { |(user, wins), idx| I18n.t('winner.top_line_html', position: idx + 1, user: user.to_s, score: wins) }
                    .join("\n")
          name = chat.winners.order(created_at: :desc).first.user.to_s
          I18n.t('winner.winner_html', top:, name: chat.winner, user: name)
        end

        before { winners }

        it 'shows top' do
          expect(send_message[:text]).to eq expected_result
        end
      end
    end
  end

  context 'when current command' do
    let(:message) { build :tg_message, :command_winner_current, message_params }

    describe 'responds with send_message' do
      subject(:send_message) { process_method[:send_message] }

      let(:participations) { create_list :participation, 15, chat: }

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
        participations
        top = chat.participations
                  .includes(:user)
                  .order(score: :desc)
                  .limit(10)
                  .each_with_index
                  .map do |p, i|
                    I18n.t('winner.top_line_html', position: i + 1, user: p.user.to_s, score: p.score) if p.user.present?
                  end.compact.join("\n")
        expected_result = I18n.t('winner.current_html', top:)

        expect(send_message[:text]).to eq expected_result
      end
    end
  end

  context 'when enable command' do
    let(:message) { build :tg_message, :command_winner_enable, message_params }

    it 'changes winner attribute' do
      expect do
        process_method
        chat.reload
      end.to change(chat, :winner).to(message.text.split.last)
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

  context 'when disable command' do
    let(:message) { build :tg_message, :command_winner_disable, message_params }

    it 'changes winner attribute' do
      expect do
        process_method
        chat.reload
      end.to change(chat, :winner).to(nil)
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
