module Filters
  class HardBlur
    RADIUS = "0x8".freeze

    def initialize(image_class: MiniMagick::Image)
      @image_class = image_class
    end

    def apply(path)
      image = @image_class.open(path)
      image.blur(RADIUS)
      image.write(path)
      path
    end
  end
end
