# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Winner, type: :model do
  let(:winner) { create :winner, date: nil }

  it { is_expected.to belong_to(:chat) }
  it { is_expected.to belong_to(:user) }

  it 'has valid factory' do
    expect(winner).to be_valid
  end

  it 'assigns date to current day' do
    expect(winner.date).to eq Time.zone.today
  end
end
