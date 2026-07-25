require "rails_helper"

RSpec.describe InstagramCaption do
  it { is_expected.to validate_presence_of(:text) }
  it { is_expected.to validate_presence_of(:type_name) }
  it { is_expected.to validate_presence_of(:caption_url) }
  it { is_expected.to validate_inclusion_of(:type_name).in_array(%w[image color gradient]) }

  it "exposes type_name via the type alias" do
    caption = build(:instagram_caption, type_name: "color")
    expect(caption.type).to eq("color")
  end

  it "is valid with the factory defaults" do
    expect(build(:instagram_caption)).to be_valid
  end
end
