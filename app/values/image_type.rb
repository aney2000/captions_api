class ImageType
  TYPES = %w[image color gradient].freeze

  attr_reader :value, :error

  def initialize(raw)
    @value = raw
    @error = compute_error
  end

  def valid?
    @error.nil?
  end

  def image?
    @value == "image"
  end

  def color?
    @value == "color"
  end

  def gradient?
    @value == "gradient"
  end

  private

  def compute_error
    return :missing if @value.nil?
    return :invalid_type unless @value.is_a?(String)
    return :blank if @value.strip.empty?
    return :unsupported unless TYPES.include?(@value)

    nil
  end
end
