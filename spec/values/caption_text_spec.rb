require "rails_helper"

RSpec.describe CaptionText do
  describe "#valid?" do
    it "is valid for a normal string" do
      expect(described_class.new("hello").valid?).to be(true)
    end

    it "is valid at exactly the max length" do
      expect(described_class.new("a" * described_class::MAX_LENGTH).valid?).to be(true)
    end

    it "is invalid (missing) when nil" do
      vo = described_class.new(nil)
      expect(vo.valid?).to be(false)
      expect(vo.error).to eq(:missing)
    end

    it "is invalid (blank) for an empty string" do
      vo = described_class.new("")
      expect(vo.valid?).to be(false)
      expect(vo.error).to eq(:blank)
    end

    it "is invalid (blank) for whitespace only" do
      vo = described_class.new("   ")
      expect(vo.valid?).to be(false)
      expect(vo.error).to eq(:blank)
    end

    it "is invalid (too_long) beyond the max length" do
      vo = described_class.new("a" * (described_class::MAX_LENGTH + 1))
      expect(vo.valid?).to be(false)
      expect(vo.error).to eq(:too_long)
    end

    it "is invalid (invalid_type) for non-string input" do
      vo = described_class.new(123)
      expect(vo.valid?).to be(false)
      expect(vo.error).to eq(:invalid_type)
    end
  end

  describe "#value" do
    it "exposes the raw value" do
      expect(described_class.new("hi").value).to eq("hi")
    end
  end
end
