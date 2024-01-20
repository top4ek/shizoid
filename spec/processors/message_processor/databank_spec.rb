# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageProcessor::Databank, type: :processor do
  subject(:process_method) { described_class.new(message).process }

  let(:user)           { create :user }
  let(:message_params) { { chat: { id: chat.telegram_id }, from: { id: user.id } } }
  let(:chat)           { create :chat, :disabled_random }
  let(:databanks)      { create_list :data_bank, 2 }

  context 'when empty command' do
    let(:message) { build :tg_message, :command_databank, message_params }

    describe 'responds with send_message' do
      subject(:send_message) { process_method[:send_message] }

      let(:expected_result) do
        databanks = DataBank.pluck(:id, :name).to_h
        list = databanks.map { |id, name| I18n.t('.databank.list_line_html', id:, name:) }.join("\n")
        active = chat.data_bank_ids.present? ? chat.data_bank_ids.to_sentence : I18n.t('false')
        I18n.t('.databank.list_html', list:, active:)
      end

      before { databanks }

      it 'chat_id' do
        expect(send_message[:chat_id]).to eq chat.telegram_id
      end

      it 'reply_to_message_id' do
        expect(send_message[:reply_to_message_id]).to eq message.message_id
      end

      it 'parse_mode' do
        expect(send_message[:parse_mode]).to eq :html
      end

      context "when there's no databank set" do
        let(:chat) { create :chat, :disabled_random, data_bank_ids: [] }

        it 'shows current status' do
          expect(send_message[:text]).to eq expected_result
        end
      end

      context 'when some databanks are enabled' do
        let(:chat) { create :chat, :disabled_random, data_bank_ids: databanks.map(&:id) }

        it 'shows current status' do
          expect(send_message[:text]).to eq expected_result
        end
      end
    end
  end

  context 'when enable command' do
    let(:chat) { create :chat, :disabled_random, data_bank_ids: [] }

    context 'with databank id' do
      let(:databank_id) { databanks.sample.id }
      let(:message) do
        build :tg_message,
              :command_databank_disable,
              message_params.merge(text: "/databank enable #{databank_id}")
      end

      it 'adds specified data_bank_id' do
        expect do
          process_method
          chat.reload
        end.to change(chat, :data_bank_ids).to([databank_id])
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

    context 'without databank id' do
      let(:message) { build :tg_message, :command_databank_enable, message_params }
      let(:chat) { create :chat, :disabled_random, data_bank_ids: databanks.map(&:id) }

      it "doesn't change data_bank_ids attribute" do
        expect do
          process_method
          chat.reload
        end.not_to change(chat, :data_bank_ids)
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
          expect(I18n.t('.nok')).to include send_message[:text]
        end
      end
    end
  end

  context 'when disable command' do
    let(:chat) { create :chat, :disabled_random, data_bank_ids: databanks.map(&:id) }

    context 'with databank id' do
      let(:databank_id) { databanks.sample.id }
      let(:message) do
        build :tg_message,
              :command_databank_disable,
              message_params.merge(text: "/databank disable #{databank_id}")
      end

      it 'removes specified data_bank_id' do
        expect do
          process_method
          chat.reload
        end.to change(chat, :data_bank_ids).to(databanks.map(&:id) - [databank_id])
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

    context 'without databank id' do
      let(:message) { build :tg_message, :command_databank_disable, message_params }

      it 'resets data_bank_ids attribute' do
        expect do
          process_method
          chat.reload
        end.to change(chat, :data_bank_ids).to([])
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
end
