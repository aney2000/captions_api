require "rails_helper"

RSpec.describe LoginUser do
  let(:hasher) { instance_double(PasswordHasher) }
  subject(:service) { described_class.new(hasher: hasher) }

  it "returns 200 with the token for valid credentials" do
    user = create(:user, username: "mr_bean", password_digest: "digest", token: "tok-9")
    allow(hasher).to receive(:verify).with("test123", "digest").and_return(true)

    result = service.call(username: "mr_bean", password: "test123")

    expect(result.success?).to be(true)
    expect(result.payload).to eq({ token: "tok-9" })
  end

  it "returns 401 when the user does not exist" do
    result = service.call(username: "ghost", password: "x")
    expect(result.status).to eq(401)
  end

  it "returns 401 when the password does not match" do
    create(:user, username: "mr_bean", password_digest: "digest")
    allow(hasher).to receive(:verify).and_return(false)

    result = service.call(username: "mr_bean", password: "wrong")
    expect(result.status).to eq(401)
  end

  it "returns 401 when credentials are blank" do
    result = service.call(username: "", password: "")
    expect(result.status).to eq(401)
  end
end
