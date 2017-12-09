require 'rails_helper'

RSpec.describe Pair, type: :model do
  let(:pair) { FactoryBot.create :pair }

  it 'has valid factory' do
    expect(pair).to be_valid
  end
end
