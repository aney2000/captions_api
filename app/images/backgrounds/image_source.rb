module Backgrounds
  # Prepares an uploaded image as an instagram background: download then resize.
  class ImageSource
    def initialize(downloader:, processor:, width:, height:)
      @downloader = downloader
      @processor = processor
      @width = width
      @height = height
    end

    def build(filename:, attrs:)
      path = @downloader.download(url: attrs[:url], filename: filename)
      @processor.resize(path: path, width: @width, height: @height)
      path
    end
  end
end
