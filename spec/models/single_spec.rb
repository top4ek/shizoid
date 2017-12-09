require 'rails_helper'

RSpec.describe Single, type: :model do
  let(:single) { FactoryBot.create :single }

  it 'has valid factory' do
    expect(single).to be_valid
  end

end
