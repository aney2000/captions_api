module Filters
  class LightBlur
    RADIUS = "0x2".freeze

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
