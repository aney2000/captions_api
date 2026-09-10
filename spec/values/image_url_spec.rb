require "rails_helper"

RSpec.describe ImageUrl do
  describe "#valid?" do
    it "is valid for an http jpg url" do
      expect(described_class.new("http://example.com/a.jpg").valid?).to be(true)
    end

    it "is valid for an https png url" do
      expect(described_class.new("https://example.com/a.png").valid?).to be(true)
    end

    it "is valid for a jpeg url" do
      expect(described_class.new("https://example.com/a.jpeg").valid?).to be(true)
    end

    it "is case-insensitive on the extension" do
      expect(described_class.new("https://example.com/A.JPG").valid?).to be(true)
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

    it "is invalid (not_http) for an ftp scheme" do
      vo = described_class.new("ftp://example.com/a.jpg")
      expect(vo.valid?).to be(false)
      expect(vo.error).to eq(:not_http)
    end

    it "is invalid (unsupported_extension) for a gif" do
      vo = described_class.new("http://example.com/a.gif")
      expect(vo.valid?).to be(false)
      expect(vo.error).to eq(:unsupported_extension)
    end

    it "is invalid (unsupported_extension) when there is no extension" do
      vo = described_class.new("http://example.com/image")
      expect(vo.valid?).to be(false)
      expect(vo.error).to eq(:unsupported_extension)
    end

    it "is invalid (invalid_type) for non-string input" do
      vo = described_class.new(42)
      expect(vo.valid?).to be(false)
      expect(vo.error).to eq(:invalid_type)
    end
  end
end
