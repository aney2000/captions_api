require "rails_helper"

RSpec.describe CreateCaption do
  let(:store) { ImageStore.new(dir: "/tmp/imgs", host: "http://test.host") }
  let(:downloader) { instance_double(ImageDownloader) }
  let(:processor) { instance_double(ImageProcessor) }
  subject(:service) do
    described_class.new(store: store, downloader: downloader, processor: processor)
  end

  def stub_pipeline
    allow(downloader).to receive(:download).and_return("/tmp/imgs/file.jpg")
    allow(processor).to receive(:add_text).and_return("/tmp/imgs/file.jpg")
  end

  it "creates a caption and returns 201 with the serialized payload" do
    stub_pipeline
    result = service.call(url: "http://example.com/a.jpg", text: "hello")

    expect(result.status).to eq(201)
    expect(result.payload[:text]).to eq("hello")
    expect(result.payload[:url]).to eq("http://example.com/a.jpg")
    expect(result.payload[:caption_url]).to start_with("http://test.host/images/")
    expect(result.payload[:id]).to be_present
    expect(Caption.count).to eq(1)
  end

  it "downloads then draws text (correct pipeline order)" do
    stub_pipeline
    service.call(url: "http://example.com/a.jpg", text: "hello")
    expect(downloader).to have_received(:download).ordered
    expect(processor).to have_received(:add_text).ordered
  end

  it "returns 400 when url is missing" do
    result = service.call(url: nil, text: "hi")
    expect(result.status).to eq(400)
    expect(result.error[:code]).to eq("missing_parameters")
  end

  it "returns 422 when url is present but empty" do
    result = service.call(url: "", text: "hi")
    expect(result.status).to eq(422)
  end

  it "returns 422 when url has an unsupported extension" do
    result = service.call(url: "http://example.com/a.gif", text: "hi")
    expect(result.status).to eq(422)
  end

  it "returns 400 when text is missing" do
    result = service.call(url: "http://example.com/a.jpg", text: nil)
    expect(result.status).to eq(400)
  end

  it "returns 422 when text is blank" do
    result = service.call(url: "http://example.com/a.jpg", text: "")
    expect(result.status).to eq(422)
  end

  it "does not persist when validation fails" do
    service.call(url: nil, text: nil)
    expect(Caption.count).to eq(0)
  end

  it "returns 422 when the image cannot be downloaded" do
    allow(downloader).to receive(:download).and_raise(ImageDownloader::DownloadError, "boom")

    result = service.call(url: "http://example.com/a.jpg", text: "hi")

    expect(result.status).to eq(422)
    expect(result.error[:code]).to eq("invalid_parameter")
    expect(Caption.count).to eq(0)
  end
end
