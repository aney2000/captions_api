require "rails_helper"

RSpec.describe CreateMeme do
  let(:store) { ImageStore.new(dir: "/tmp/imgs", host: "http://test.host") }
  let(:downloader) { instance_double(ImageDownloader) }
  let(:processor) { instance_double(ImageProcessor) }
  subject(:service) do
    described_class.new(store: store, downloader: downloader, processor: processor)
  end

  it "returns 303 with the generated caption_url" do
    allow(downloader).to receive(:download).and_return("/tmp/imgs/m.jpg")
    allow(processor).to receive(:add_text).and_return("/tmp/imgs/m.jpg")

    result = service.call(image_url: "http://example.com/a.jpg", text: "yo")

    expect(result.status).to eq(303)
    expect(result.payload[:caption_url]).to start_with("http://test.host/images/")
  end

  it "returns 400 when image_url is missing" do
    expect(service.call(image_url: nil, text: "hi").status).to eq(400)
  end

  it "returns 422 when text is blank" do
    expect(service.call(image_url: "http://example.com/a.jpg", text: "").status).to eq(422)
  end
end
