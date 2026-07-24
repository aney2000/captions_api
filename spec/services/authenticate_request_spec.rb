require "rails_helper"

RSpec.describe AuthenticateRequest do
  subject(:service) { described_class.new }

  it "resolves a valid bearer token to the user" do
    user = create(:user, token: "abc123")
    result = service.call("Bearer abc123")

    expect(result.success?).to be(true)
    expect(result.payload).to eq(user)
  end

  it "is case-insensitive on the Bearer keyword" do
    user = create(:user, token: "abc123")
    result = service.call("bearer abc123")
    expect(result.payload).to eq(user)
  end

  it "returns 401 when the header is missing" do
    result = service.call(nil)
    expect(result.status).to eq(401)
    expect(result.error[:code]).to eq("unauthorized")
  end

  it "returns 401 when the header is not a bearer token" do
    result = service.call("Basic xyz")
    expect(result.status).to eq(401)
  end

  it "returns 401 when the token matches no user" do
    result = service.call("Bearer nonexistent")
    expect(result.status).to eq(401)
  end
end
