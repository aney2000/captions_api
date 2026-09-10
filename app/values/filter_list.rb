class FilterList
  attr_reader :value, :error

  def initialize(raw, catalog: Filters::Catalog)
    @catalog = catalog
    @value = normalize(raw)
    @error = compute_error(raw)
  end

  def valid?
    @error.nil?
  end

  def present?
    !@value.empty?
  end

  def names
    @value
  end

  def build
    @value.map { |name| @catalog.build(name) }
  end

  private

  def normalize(raw)
    return [] unless raw.is_a?(String) || raw.is_a?(Array)

    Array(raw).map(&:to_s)
  end

  def compute_error(raw)
    return nil if raw.nil?
    return :invalid_type unless raw.is_a?(String) || raw.is_a?(Array)
    return :empty if @value.empty? || @value.all? { |name| name.strip.empty? }
    return :unsupported unless @value.all? { |name| @catalog.supported?(name) }

    nil
  end
end
