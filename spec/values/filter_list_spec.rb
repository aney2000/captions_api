require "rails_helper"

RSpec.describe FilterList do
  describe "#valid?" do
    it "is valid and empty when absent (nil)" do
      vo = described_class.new(nil)

      expect(vo.valid?).to be(true)
      expect(vo.present?).to be(false)
      expect(vo.names).to eq([])
    end

    it "is valid for a single supported filter given as a string" do
      vo = described_class.new("blackwhite")

      expect(vo.valid?).to be(true)
      expect(vo.present?).to be(true)
      expect(vo.names).to eq(%w[blackwhite])
    end

    it "is valid for an array of supported filters" do
      vo = described_class.new(%w[blackwhite light_blur])

      expect(vo.valid?).to be(true)
      expect(vo.names).to eq(%w[blackwhite light_blur])
    end

    it "is invalid (:empty) for an empty array" do
      expect(described_class.new([]).error).to eq(:empty)
    end

    it "is invalid (:empty) for a blank string" do
      expect(described_class.new("").error).to eq(:empty)
    end

    it "is invalid (:unsupported) for an unknown filter" do
      expect(described_class.new("sepia").error).to eq(:unsupported)
    end

    it "is invalid (:unsupported) when any filter in the array is unknown" do
      expect(described_class.new(%w[blackwhite sepia]).error).to eq(:unsupported)
    end

    it "is invalid (:invalid_type) for a non string/array value" do
      expect(described_class.new(123).error).to eq(:invalid_type)
    end
  end

  describe "#build" do
    it "materializes a filter strategy for each name" do
      built = described_class.new(%w[blackwhite light_blur]).build

      expect(built.map(&:class)).to eq([ Filters::Blackwhite, Filters::LightBlur ])
    end

    it "returns an empty array when absent" do
      expect(described_class.new(nil).build).to eq([])
    end
  end
end
