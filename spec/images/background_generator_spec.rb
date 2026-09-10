require "rails_helper"

RSpec.describe BackgroundGenerator do
  let(:tool) { spy("magick tool") }
  let(:convert) { ->(&block) { block.call(tool) } }
  subject(:generator) { described_class.new(convert: convert) }

  describe "#solid" do
    it "builds a solid canvas of the given size and color, writing to path" do
      result = generator.solid(path: "/tmp/bg.jpg", color: "#003166", width: 1080, height: 1080)

      expect(tool).to have_received(:size).with("1080x1080")
      expect(tool).to have_received(:<<).with("xc:#003166")
      expect(tool).to have_received(:<<).with("/tmp/bg.jpg")
      expect(result).to eq("/tmp/bg.jpg")
    end
  end

  describe "#gradient" do
    it "builds a gradient canvas from start to end color, writing to path" do
      result = generator.gradient(
        path: "/tmp/bg.jpg", start_color: "#000000", end_color: "#003166", width: 1080, height: 1350
      )

      expect(tool).to have_received(:size).with("1080x1350")
      expect(tool).to have_received(:<<).with("gradient:#000000-#003166")
      expect(tool).to have_received(:<<).with("/tmp/bg.jpg")
      expect(result).to eq("/tmp/bg.jpg")
    end
  end
end
