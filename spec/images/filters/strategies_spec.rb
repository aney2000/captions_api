require "rails_helper"

RSpec.describe "Filter strategies" do
  let(:fake_image) { double("MiniMagick::Image", colorspace: nil, blur: nil, write: nil) }
  let(:image_class) { double("MiniMagick::Image class", open: fake_image) }

  describe Filters::Blackwhite do
    it "converts to Gray colorspace and writes back" do
      path = described_class.new(image_class: image_class).apply("/tmp/a.jpg")
      expect(fake_image).to have_received(:colorspace).with("Gray")
      expect(fake_image).to have_received(:write).with("/tmp/a.jpg")
      expect(path).to eq("/tmp/a.jpg")
    end
  end

  describe Filters::LightBlur do
    it "applies a light blur radius" do
      described_class.new(image_class: image_class).apply("/tmp/a.jpg")
      expect(fake_image).to have_received(:blur).with(Filters::LightBlur::RADIUS)
    end
  end

  describe Filters::HardBlur do
    it "applies a hard blur radius" do
      described_class.new(image_class: image_class).apply("/tmp/a.jpg")
      expect(fake_image).to have_received(:blur).with(Filters::HardBlur::RADIUS)
    end
  end
end
