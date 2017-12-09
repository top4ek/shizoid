require 'rails_helper'

RSpec.describe Greeting, type: :model do
  let(:greeting) { FactoryBot.create :greeting }

  it 'has valid factory' do
    expect(greeting).to be_valid
  end
end
