module Backgrounds
  # Maps an instagram background type to its source strategy.
  class Catalog
    def initialize(downloader:, processor:, generator:, store:, width:, height:)
      @strategies = {
        "image" => ImageSource.new(downloader: downloader, processor: processor, width: width, height: height),
        "color" => ColorSource.new(generator: generator, store: store, width: width, height: height),
        "gradient" => GradientSource.new(generator: generator, store: store, width: width, height: height)
      }
    end

    def for_type(type)
      @strategies.fetch(type)
    end
  end
end
