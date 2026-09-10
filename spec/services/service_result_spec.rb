require "rails_helper"

RSpec.describe ServiceResult do
  describe ".success" do
    it "is successful and carries payload + status" do
      result = described_class.success(payload: { a: 1 }, status: 201)
      expect(result.success?).to be(true)
      expect(result.failure?).to be(false)
      expect(result.payload).to eq({ a: 1 })
      expect(result.status).to eq(201)
    end

    it "defaults status to 200" do
      expect(described_class.success(payload: {}).status).to eq(200)
    end
  end

  describe ".failure" do
    it "is a failure and carries error + status" do
      error = { code: "x", title: "t", description: "d" }
      result = described_class.failure(error: error, status: 422)
      expect(result.failure?).to be(true)
      expect(result.success?).to be(false)
      expect(result.error).to eq(error)
      expect(result.status).to eq(422)
    end
  end
end
