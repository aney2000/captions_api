require "open-uri"
require "fileutils"

class ImageDownloader
  class DownloadError < StandardError; end

  ACCEPTED_CONTENT_TYPES = %w[image/jpeg image/jpg image/png].freeze

  def initialize(dir:)
    @dir = dir
  end

  def download(url:, filename:)
    FileUtils.mkdir_p(@dir)
    path = File.join(@dir, filename)

    URI.open(url) do |remote|
      ensure_supported!(url, remote.content_type)
      File.binwrite(path, remote.read)
    end

    path
  rescue OpenURI::HTTPError, SocketError, Errno::ECONNREFUSED => e
    raise DownloadError, "failed to download #{url}: #{e.message}"
  end

  private

  def ensure_supported!(url, content_type)
    return if ACCEPTED_CONTENT_TYPES.include?(content_type)

    raise DownloadError, "unsupported content type #{content_type.inspect} for #{url}"
  end
end
