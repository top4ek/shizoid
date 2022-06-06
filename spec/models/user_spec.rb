# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:tg_user) { build :tg_user }
  let(:user)    { create :user, id: tg_user.id }
  let(:message) { build :tg_message, from: tg_user }

  it { should have_many(:chats).through(:participations) }

  it 'has valid factory' do
    expect(user).to be_valid
  end

  it '#to_link returns name as html' do
    link = "<a href='tg://user?id=#{user.id}'>#{user}</a>"
    expect(user.to_link).to eq link
  end

  it '#to_s returns name as string' do
    name = user.username || user.first_name || user.last_name
    expect(user.to_s).to eq name
  end

  describe 'update_casban' do
    subject(:update_result) { user.update_casban }

    before { webmocks(:cas, :check, telegram_id: user.id, banned: true) }

    context 'when already updated' do
      let(:user) { create :user, :casbanned, casbanchecked_at: 1.day.ago.round }

      it "doesn't call CasService" do
        allow(CasService).to receive(:banned?)
        update_result
        expect(CasService).not_to have_received(:banned?)
      end

      it "doesn't update casbanchecked_at and casbanned_at" do
        user
        expect do
          update_result
          user.reload
        end.not_to change(user, :casbanchecked_at)
      end
    end

    context 'when first time to update' do
      let(:user) { create :user, casbanned_at: nil, casbanchecked_at: nil }

      it 'updates casbanchecked_at and casbanned_at' do
        user
        expect do
          update_result
          user.reload
        end.to(change(user, :casbanned_at)
          .and(change(user, :casbanchecked_at)))
      end

      it 'calls CasService' do
        allow(CasService).to receive(:banned?)
        update_result
        expect(CasService).to have_received(:banned?).with(user.id)
      end
    end
  end

  describe 'learn' do
    subject(:learn_result) { described_class.learn(tg_user) }

    it 'creates user' do
      expect { learn_result }.to change(described_class, :count).by(1)
    end

    it "doesn't create new user" do
      user
      expect { learn_result }.not_to change(described_class, :count)
    end

    %i[username first_name last_name].each do |attr|
      it "updates users's #{attr}" do
        user
        expect do
          learn_result
          user.reload
        end.to change(user, attr)
      end
    end
  end
end
