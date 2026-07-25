class HexColor
  PATTERN = /\A#\h{6}\z/

  attr_reader :value, :error

  def initialize(raw)
    @value = raw
    @error = compute_error
  end

  def valid?
    @error.nil?
  end

  # Normalized uppercase form, e.g. "#00ff66" -> "#00FF66".
  def normalized
    return nil unless valid?

    @value.upcase
  end

  private

  def compute_error
    return :missing if @value.nil?
    return :invalid_type unless @value.is_a?(String)
    return :blank if @value.strip.empty?
    return :malformed unless PATTERN.match?(@value)

    nil
  end
end
