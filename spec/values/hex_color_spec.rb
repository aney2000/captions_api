require "rails_helper"

RSpec.describe HexColor do
  describe "#valid?" do
    it "is valid for a lowercase hex color" do
      expect(described_class.new("#00ff66").valid?).to be(true)
    end

    it "is valid for an uppercase hex color" do
      expect(described_class.new("#003166").valid?).to be(true)
    end

    it "is invalid (missing) when nil" do
      vo = described_class.new(nil)
      expect(vo.valid?).to be(false)
      expect(vo.error).to eq(:missing)
    end

    it "is invalid (blank) when empty" do
      vo = described_class.new("")
      expect(vo.valid?).to be(false)
      expect(vo.error).to eq(:blank)
    end

    it "is invalid (malformed) without a leading #" do
      vo = described_class.new("003166")
      expect(vo.valid?).to be(false)
      expect(vo.error).to eq(:malformed)
    end

    it "is invalid (malformed) with 3-digit shorthand" do
      vo = described_class.new("#036")
      expect(vo.valid?).to be(false)
      expect(vo.error).to eq(:malformed)
    end

    it "is invalid (malformed) with non-hex characters" do
      vo = described_class.new("#00zz66")
      expect(vo.valid?).to be(false)
      expect(vo.error).to eq(:malformed)
    end
  end

  describe "#normalized" do
    it "uppercases a valid color" do
      expect(described_class.new("#00ff66").normalized).to eq("#00FF66")
    end

    it "returns nil for an invalid color" do
      expect(described_class.new("nope").normalized).to be_nil
    end
  end
end
