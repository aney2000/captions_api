require "rails_helper"

RSpec.describe ImageType do
  describe "#valid?" do
    ImageType::TYPES.each do |type|
      it "is valid for #{type}" do
        expect(described_class.new(type).valid?).to be(true)
      end
    end

    it "is invalid (:missing) when nil" do
      vo = described_class.new(nil)
      expect(vo.valid?).to be(false)
      expect(vo.error).to eq(:missing)
    end

    it "is invalid (:blank) for an empty string" do
      vo = described_class.new("")
      expect(vo.valid?).to be(false)
      expect(vo.error).to eq(:blank)
    end

    it "is invalid (:invalid_type) for a non-string" do
      vo = described_class.new(123)
      expect(vo.valid?).to be(false)
      expect(vo.error).to eq(:invalid_type)
    end

    it "is invalid (:unsupported) for an unknown type" do
      vo = described_class.new("video")
      expect(vo.valid?).to be(false)
      expect(vo.error).to eq(:unsupported)
    end
  end

  describe "predicates" do
    it "reports image?" do
      expect(described_class.new("image").image?).to be(true)
      expect(described_class.new("color").image?).to be(false)
    end

    it "reports color?" do
      expect(described_class.new("color").color?).to be(true)
      expect(described_class.new("image").color?).to be(false)
    end

    it "reports gradient?" do
      expect(described_class.new("gradient").gradient?).to be(true)
      expect(described_class.new("image").gradient?).to be(false)
    end
  end
end
