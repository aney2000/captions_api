require "rails_helper"

RSpec.describe ImageProcessor do
  let(:fake_image) { double("MiniMagick::Image", combine_options: nil, resize: nil, write: nil) }
  let(:image_class) { double("MiniMagick::Image class", open: fake_image) }

  subject(:processor) { described_class.new(image_class: image_class) }

  describe "#add_text" do
    it "opens the path, combines options, writes back, and returns the path" do
      allow(fake_image).to receive(:combine_options).and_yield(double("cmd").as_null_object)

      result = processor.add_text(path: "/tmp/a.jpg", text: "hello")

      expect(image_class).to have_received(:open).with("/tmp/a.jpg")
      expect(fake_image).to have_received(:write).with("/tmp/a.jpg")
      expect(result).to eq("/tmp/a.jpg")
    end
  end

  describe "#resize" do
    it "opens the path, resizes to the exact dimensions, writes back, and returns the path" do
      result = processor.resize(path: "/tmp/a.jpg", width: 1080, height: 1350)

      expect(image_class).to have_received(:open).with("/tmp/a.jpg")
      expect(fake_image).to have_received(:resize).with("1080x1350!")
      expect(fake_image).to have_received(:write).with("/tmp/a.jpg")
      expect(result).to eq("/tmp/a.jpg")
    end
  end
end
