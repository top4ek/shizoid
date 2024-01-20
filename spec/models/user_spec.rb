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
