require 'rails_helper'

RSpec.describe 'Locales' do
  it 'are bright and shiny' do
    Localer.configure
    expect(Localer.data.missing_translations).to be_empty
  end
end
