require "rails_helper"

RSpec.describe Filters::Catalog do
  describe ".supported?" do
    it "is true for known filters" do
      expect(described_class.supported?("blackwhite")).to be(true)
      expect(described_class.supported?("light_blur")).to be(true)
      expect(described_class.supported?("hard_blur")).to be(true)
    end

    it "is false for unknown filters" do
      expect(described_class.supported?("sepia")).to be(false)
    end
  end

  describe ".names" do
    it "lists all supported filter names" do
      expect(described_class.names).to contain_exactly("blackwhite", "light_blur", "hard_blur")
    end
  end

  describe ".build" do
    it "builds a strategy instance for a known name" do
      expect(described_class.build("blackwhite")).to be_a(Filters::Blackwhite)
    end

    it "returns nil for an unknown name" do
      expect(described_class.build("nope")).to be_nil
    end
  end
end
