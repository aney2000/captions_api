require "rails_helper"

RSpec.describe "Background sources" do
  describe Backgrounds::ImageSource do
    let(:downloader) { instance_double(ImageDownloader) }
    let(:processor) { instance_double(ImageProcessor) }
    subject(:source) do
      described_class.new(downloader: downloader, processor: processor, width: 1080, height: 1080)
    end

    it "downloads the image then resizes it to the target size" do
      allow(downloader).to receive(:download)
        .with(url: "http://example.com/a.jpg", filename: "f.jpg").and_return("/imgs/f.jpg")
      allow(processor).to receive(:resize).and_return("/imgs/f.jpg")

      result = source.build(filename: "f.jpg", attrs: { url: "http://example.com/a.jpg" })

      expect(downloader).to have_received(:download).ordered
      expect(processor).to have_received(:resize)
        .with(path: "/imgs/f.jpg", width: 1080, height: 1080).ordered
      expect(result).to eq("/imgs/f.jpg")
    end
  end

  describe Backgrounds::ColorSource do
    let(:generator) { instance_double(BackgroundGenerator) }
    let(:store) { instance_double(ImageStore) }
    subject(:source) do
      described_class.new(generator: generator, store: store, width: 1080, height: 1080)
    end

    it "generates a solid canvas at the stored path" do
      allow(store).to receive(:path_for).with("f.jpg").and_return("/imgs/f.jpg")
      allow(generator).to receive(:solid).and_return("/imgs/f.jpg")

      result = source.build(filename: "f.jpg", attrs: { color: "#003166" })

      expect(generator).to have_received(:solid)
        .with(path: "/imgs/f.jpg", color: "#003166", width: 1080, height: 1080)
      expect(result).to eq("/imgs/f.jpg")
    end
  end

  describe Backgrounds::GradientSource do
    let(:generator) { instance_double(BackgroundGenerator) }
    let(:store) { instance_double(ImageStore) }
    subject(:source) do
      described_class.new(generator: generator, store: store, width: 1080, height: 1080)
    end

    it "generates a gradient canvas at the stored path" do
      allow(store).to receive(:path_for).with("f.jpg").and_return("/imgs/f.jpg")
      allow(generator).to receive(:gradient).and_return("/imgs/f.jpg")

      result = source.build(
        filename: "f.jpg", attrs: { start_color: "#000000", end_color: "#003166" }
      )

      expect(generator).to have_received(:gradient)
        .with(path: "/imgs/f.jpg", start_color: "#000000", end_color: "#003166", width: 1080, height: 1080)
      expect(result).to eq("/imgs/f.jpg")
    end
  end
end
