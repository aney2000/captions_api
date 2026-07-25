class ImageProcessor
  DEFAULT_POINTSIZE = 60

  def initialize(image_class: MiniMagick::Image)
    @image_class = image_class
  end

  def add_text(path:, text:)
    image = @image_class.open(path)
    image.combine_options do |c|
      c.gravity "center"
      c.pointsize DEFAULT_POINTSIZE
      c.fill "black"
      c.undercolor "white"
      c.font "Helvetica"
      c.draw "text 0,0 \x27#{escape(text)}\x27"
    end
    image.write(path)
    path
  end

  def resize(path:, width:, height:)
    image = @image_class.open(path)
    image.resize("#{width}x#{height}!")
    image.write(path)
    path
  end

  private

  def escape(text)
    text.to_s.gsub("\x27", %q(\\x27))
  end
end