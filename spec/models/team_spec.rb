require 'rails_helper'

describe Team do
  let(:team) { described_class.create }

  it 'validates the presence of a name' do
    expect(team.errors[:name]).to be_present
  end
end
