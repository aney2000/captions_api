class CaptionText
  MAX_LENGTH = 266

  attr_reader :value, :error

  def initialize(raw)
    @value = raw
    @error = compute_error
  end

  def valid?
    @error.nil?
  end

  private

  def compute_error
    return :missing if @value.nil?
    return :invalid_type unless @value.is_a?(String)
    return :blank if @value.strip.empty?
    return :too_long if @value.length > MAX_LENGTH

    nil
  end
end
