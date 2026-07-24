require "rails_helper"

RSpec.describe PasswordHasher do
  subject(:hasher) { described_class.new }

  describe "#hash" do
    it "produces a digest different from the plain password" do
      digest = hasher.hash("secret123")
      expect(digest).not_to eq("secret123")
    end

    it "produces a valid bcrypt digest" do
      digest = hasher.hash("secret123")
      expect(BCrypt::Password.new(digest)).to eq("secret123")
    end
  end

  describe "#verify" do
    let(:digest) { hasher.hash("secret123") }

    it "returns true for the correct password" do
      expect(hasher.verify("secret123", digest)).to be(true)
    end

    it "returns false for the wrong password" do
      expect(hasher.verify("wrong", digest)).to be(false)
    end

    it "returns false when the digest is nil" do
      expect(hasher.verify("secret123", nil)).to be(false)
    end

    it "returns false when the digest is malformed" do
      expect(hasher.verify("secret123", "not-a-bcrypt-hash")).to be(false)
    end
  end
end