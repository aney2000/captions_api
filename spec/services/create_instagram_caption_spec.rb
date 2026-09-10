require "rails_helper"

RSpec.describe CreateInstagramCaption do
  let(:store) { ImageStore.new(dir: "/tmp/imgs", host: "http://test.host") }
  let(:processor) { instance_double(ImageProcessor) }
  let(:catalog) { instance_double(Backgrounds::Catalog) }
  let(:source) { instance_double(Backgrounds::ImageSource) }
  subject(:service) do
    described_class.new(store: store, processor: processor, catalog: catalog)
  end

  def stub_pipeline
    allow(catalog).to receive(:for_type).and_return(source)
    allow(source).to receive(:build).and_return("/tmp/imgs/file.jpg")
    allow(processor).to receive(:add_text).and_return("/tmp/imgs/file.jpg")
  end

  describe "image type" do
    it "creates an instagram caption and returns 303 with the serialized payload" do
      stub_pipeline
      result = service.call(type: "image", url: "http://example.com/a.jpg", text: "hi")

      expect(result.status).to eq(303)
      expect(result.payload[:type]).to eq("image")
      expect(result.payload[:url]).to eq("http://example.com/a.jpg")
      expect(result.payload[:text]).to eq("hi")
      expect(result.payload[:caption_url]).to start_with("http://test.host/images/")
      expect(result.payload[:id]).to be_present
      expect(InstagramCaption.count).to eq(1)
    end

    it "builds the image background then adds the caption text" do
      stub_pipeline
      service.call(type: "image", url: "http://example.com/a.jpg", text: "hi")

      expect(catalog).to have_received(:for_type).with("image").ordered
      expect(source).to have_received(:build).ordered
      expect(processor).to have_received(:add_text).ordered
    end

    it "applies requested filters and echoes them in the payload" do
      stub_pipeline
      blackwhite = instance_double(Filters::Blackwhite)
      allow(Filters::Catalog).to receive(:build).with("blackwhite").and_return(blackwhite)
      allow(blackwhite).to receive(:apply)

      result = service.call(
        type: "image", url: "http://example.com/a.jpg", text: "hi", filter: "blackwhite"
      )

      expect(blackwhite).to have_received(:apply).with("/tmp/imgs/file.jpg")
      expect(result.payload[:filter]).to eq(%w[blackwhite])
    end
  end

  describe "color type" do
    it "creates a color caption without a url and returns 303" do
      stub_pipeline
      result = service.call(type: "color", color: "#003166", text: "hi")

      expect(result.status).to eq(303)
      expect(result.payload[:type]).to eq("color")
      expect(result.payload[:url]).to be_nil
      expect(InstagramCaption.count).to eq(1)
    end
  end

  describe "gradient type" do
    it "creates a gradient caption and returns 303" do
      stub_pipeline
      result = service.call(
        type: "gradient", start_color: "#000000", end_color: "#003166", text: "hi"
      )

      expect(result.status).to eq(303)
      expect(result.payload[:type]).to eq("gradient")
    end
  end

  describe "validation failures" do
    it "returns 400 when type is missing" do
      expect(service.call(type: nil, text: "hi").status).to eq(400)
    end

    it "returns 422 for an unsupported type" do
      expect(service.call(type: "video", text: "hi").status).to eq(422)
    end

    it "returns 400 when text is missing" do
      result = service.call(type: "image", url: "http://example.com/a.jpg", text: nil)
      expect(result.status).to eq(400)
    end

    it "returns 400 when the image url is missing" do
      expect(service.call(type: "image", url: nil, text: "hi").status).to eq(400)
    end

    it "returns 422 when the image url is invalid" do
      result = service.call(type: "image", url: "http://example.com/a.gif", text: "hi")
      expect(result.status).to eq(422)
    end

    it "returns 400 when color is missing for the color type" do
      expect(service.call(type: "color", color: nil, text: "hi").status).to eq(400)
    end

    it "returns 422 when color is malformed" do
      expect(service.call(type: "color", color: "003166", text: "hi").status).to eq(422)
    end

    it "returns 400 when start_color is missing for the gradient type" do
      result = service.call(type: "gradient", end_color: "#003166", text: "hi")
      expect(result.status).to eq(400)
    end

    it "returns 422 when a filter is requested for a non-image type" do
      result = service.call(type: "color", color: "#003166", text: "hi", filter: "blackwhite")
      expect(result.status).to eq(422)
    end

    it "returns 422 for an unsupported filter" do
      result = service.call(type: "image", url: "http://example.com/a.jpg", text: "hi", filter: "sepia")
      expect(result.status).to eq(422)
    end

    it "does not persist when validation fails" do
      service.call(type: nil, text: nil)
      expect(InstagramCaption.count).to eq(0)
    end

    it "returns 422 when the image background cannot be downloaded" do
      allow(catalog).to receive(:for_type).and_return(source)
      allow(source).to receive(:build).and_raise(ImageDownloader::DownloadError, "boom")

      result = service.call(type: "image", url: "http://example.com/a.jpg", text: "hi")

      expect(result.status).to eq(422)
      expect(result.error[:code]).to eq("invalid_parameter")
      expect(InstagramCaption.count).to eq(0)
    end
  end
end
