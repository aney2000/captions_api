require "rails_helper"

RSpec.describe InstagramCaption do
  subject(:instagram_caption) { build(:instagram_caption) }

  it "is valid with factory defaults" do
    expect(instagram_caption).to be_valid
  end

  it { is_expected.to validate_presence_of(:text) }
  it { is_expected.to validate_presence_of(:type_name) }
  it { is_expected.to validate_inclusion_of(:type_name).in_array(InstagramCaption::TYPES) }

  it "exposes type as an alias of type_name" do
    caption = build(:instagram_caption, type_name: "color")
    expect(caption.type).to eq("color")
  end

  describe "url presence depends on type" do
    it "requires url when type is image" do
      caption = build(:instagram_caption, type_name: "image", url: nil)

      expect(caption).not_to be_valid
      expect(caption.errors[:url]).to be_present
    end

    it "does not require url when type is color" do
      caption = build(:instagram_caption, type_name: "color", url: nil)

      expect(caption).to be_valid
    end

    it "does not require url when type is gradient" do
      caption = build(:instagram_caption, type_name: "gradient", url: nil)

      expect(caption).to be_valid
    end
  end
end
