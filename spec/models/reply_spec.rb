require 'rails_helper'

RSpec.describe Reply, type: :model do
  let(:reply) { FactoryBot.create :reply }

  it 'has valid factory' do
    expect(reply).to be_valid
  end
end
