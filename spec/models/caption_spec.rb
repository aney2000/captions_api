require "rails_helper"

RSpec.describe Caption do
  it { is_expected.to validate_presence_of(:url) }
  it { is_expected.to validate_presence_of(:text) }
  it { is_expected.to validate_presence_of(:caption_url) }

  it "is valid with the factory defaults" do
    expect(build(:caption)).to be_valid
  end
end
