require "rails_helper"
require "tmpdir"
require "webmock/rspec"

RSpec.describe ImageDownloader do
  around do |example|
    Dir.mktmpdir do |temp_dir|
      @dir = temp_dir
      example.run
    end
  end

  subject(:downloader) { described_class.new(dir: @dir) }

  it "downloads the remote body to <dir>/<filename> and returns the path" do
    stub_request(:get, "http://example.com/a.jpg")
      .to_return(status: 200, body: "IMG-BYTES", headers: { "Content-Type" => "image/jpeg" })

    path = downloader.download(url: "http://example.com/a.jpg", filename: "out.jpg")

    expect(path).to eq(File.join(@dir, "out.jpg"))
    expect(File.read(path)).to eq("IMG-BYTES")
  end

  it "raises DownloadError on an HTTP error" do
    stub_request(:get, "http://example.com/missing.jpg")
      .to_return(status: 404)

    expect {
      downloader.download(url: "http://example.com/missing.jpg", filename: "x.jpg")
    }.to raise_error(ImageDownloader::DownloadError)
  end

  it "raises DownloadError when the response is not a supported image type" do
    stub_request(:get, "http://example.com/page.jpg")
      .to_return(status: 200, body: "<html></html>", headers: { "Content-Type" => "text/html" })

    expect {
      downloader.download(url: "http://example.com/page.jpg", filename: "x.jpg")
    }.to raise_error(ImageDownloader::DownloadError)
  end
end
