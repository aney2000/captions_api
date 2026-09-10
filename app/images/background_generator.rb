require "mini_magick"

# Generates background canvases (solid color or gradient) at a given size.
# Wraps ImageMagick's `convert` builder; the command runner is injectable
# so it can be exercised without shelling out in tests.
class BackgroundGenerator
  def initialize(convert: MiniMagick.method(:convert))
    @convert = convert
  end

  def solid(path:, color:, width:, height:)
    @convert.call do |c|
      c.size("#{width}x#{height}")
      c << "xc:#{color}"
      c << path
    end
    path
  end

  def gradient(path:, start_color:, end_color:, width:, height:)
    @convert.call do |c|
      c.size("#{width}x#{height}")
      c << "gradient:#{start_color}-#{end_color}"
      c << path
    end
    path
  end
end
