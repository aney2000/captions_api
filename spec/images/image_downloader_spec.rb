require "rails_helper"

RSpec.describe ImageDownloader do
  let(:dir) { Dir.mktmpdir }
  subject(:downloader) { described_class.new(dir: dir) }

  after { FileUtils.remove_entry(dir) if File.directory?(dir) }

  it "downloads the remote body to <dir>/<filename> and returns the path" do
    stub_request(:get, "http://example.com/a.jpg")
      .to_return(status: 200, body: "IMG-BYTES")

    path = downloader.download(url: "http://example.com/a.jpg", filename: "out.jpg")

    expect(path).to eq(File.join(dir, "out.jpg"))
    expect(File.read(path)).to eq("IMG-BYTES")
  end

  it "raises DownloadError on an HTTP error" do
    stub_request(:get, "http://example.com/missing.jpg").to_return(status: 404)

    expect {
      downloader.download(url: "http://example.com/missing.jpg", filename: "x.jpg")
    }.to raise_error(ImageDownloader::DownloadError)
  end
end
