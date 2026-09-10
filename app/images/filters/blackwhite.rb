module Filters
  class Blackwhite
    def initialize(image_class: MiniMagick::Image)
      @image_class = image_class
    end

    def apply(path)
      image = @image_class.open(path)
      image.colorspace("Gray")
      image.write(path)
      path
    end
  end
end
