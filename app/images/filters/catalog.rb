module Filters
  module Catalog
    STRATEGIES = {
      "blackwhite" => Filters::Blackwhite,
      "light_blur" => Filters::LightBlur,
      "hard_blur"  => Filters::HardBlur
    }.freeze

    module_function

    def supported?(name)
      STRATEGIES.key?(name)
    end

    def names
      STRATEGIES.keys
    end

    def build(name)
      klass = STRATEGIES[name]
      klass&.new
    end
  end
end
