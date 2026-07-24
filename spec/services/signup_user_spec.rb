require "rails_helper"

RSpec.describe SignupUser do
  let(:hasher) { instance_double(PasswordHasher, hash: "hashed-pw") }
  let(:token_generator) { instance_double(TokenGenerator, generate: "tok-123") }
  subject(:service) { described_class.new(hasher: hasher, token_generator: token_generator) }

  it "creates a user and returns a 201 with the token" do
    result = service.call(username: "mr_bean", password: "test123")

    expect(result.success?).to be(true)
    expect(result.status).to eq(201)
    expect(result.payload).to eq({ token: "tok-123" })
    expect(User.find_by(username: "mr_bean").password_digest).to eq("hashed-pw")
  end

  it "returns 400 when username is blank" do
    result = service.call(username: "", password: "test123")
    expect(result.status).to eq(400)
    expect(result.error[:code]).to eq("missing_parameters")
  end

  it "returns 400 when password is blank" do
    result = service.call(username: "mr_bean", password: "  ")
    expect(result.status).to eq(400)
  end

  it "returns 409 when the username already exists" do
    create(:user, username: "mr_bean")
    result = service.call(username: "mr_bean", password: "test123")
    expect(result.status).to eq(409)
    expect(result.error[:code]).to eq("conflict")
  end
end
