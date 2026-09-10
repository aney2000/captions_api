module Backgrounds
  # Builds a solid color background at the target instagram size.
  class ColorSource
    def initialize(generator:, store:, width:, height:)
      @generator = generator
      @store = store
      @width = width
      @height = height
    end

    def build(filename:, attrs:)
      @generator.solid(
        path: @store.path_for(filename),
        color: attrs[:color],
        width: @width,
        height: @height
      )
    end
  end
end
