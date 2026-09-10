require "uri"

class ImageUrl
  ACCEPTED_EXTENSIONS = %w[.jpg .jpeg .png].freeze

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

    uri = safe_parse(@value)
    return :malformed if uri.nil?
    return :not_http unless uri.is_a?(URI::HTTP)
    return :unsupported_extension unless accepted_extension?(uri.path)

    nil
  end

  def safe_parse(str)
    URI.parse(str)
  rescue URI::InvalidURIError
    nil
  end

  def accepted_extension?(path)
    ext = File.extname(path.to_s).downcase
    ACCEPTED_EXTENSIONS.include?(ext)
  end
end
