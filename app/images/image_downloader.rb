require "open-uri"
require "fileutils"

class ImageDownloader
  class DownloadError < StandardError; end

  def initialize(dir:)
    @dir = dir
  end

  def download(url:, filename:)
    FileUtils.mkdir_p(@dir)
    path = File.join(@dir, filename)
    URI.parse(url).open do |remote|
      File.binwrite(path, remote.read)
    end
    path
  rescue OpenURI::HTTPError, SocketError, Errno::ECONNREFUSED => e
    raise DownloadError, "failed to download #{url}: #{e.message}"
  end
end
