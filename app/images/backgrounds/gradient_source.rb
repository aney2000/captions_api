module Backgrounds
  # Builds a gradient background at the target instagram size.
  class GradientSource
    def initialize(generator:, store:, width:, height:)
      @generator = generator
      @store = store
      @width = width
      @height = height
    end

    def build(filename:, attrs:)
      @generator.gradient(
        path: @store.path_for(filename),
        start_color: attrs[:start_color],
        end_color: attrs[:end_color],
        width: @width,
        height: @height
      )
    end
  end
end
