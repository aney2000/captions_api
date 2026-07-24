require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "POST /signup" do
    it "creates a user and returns 201 with a token" do
      post "/signup", params: { user: { username: "mr_bean", password: "test123" } }, as: :json

      expect(response).to have_http_status(201)
      expect(response.parsed_body["user"]).to have_key("token")
    end

    it "returns 400 when username is blank" do
      post "/signup", params: { user: { username: "", password: "test123" } }, as: :json
      expect(response).to have_http_status(400)
    end

    it "returns 409 when the user already exists" do
      create(:user, username: "mr_bean")
      post "/signup", params: { user: { username: "mr_bean", password: "test123" } }, as: :json
      expect(response).to have_http_status(409)
    end
  end

  describe "POST /login" do
    it "returns 200 with a token for valid credentials" do
      hasher = PasswordHasher.new
      create(:user, username: "mr_bean", password_digest: hasher.hash("test123"), token: "tok-1")

      post "/login", params: { user: { username: "mr_bean", password: "test123" } }, as: :json

      expect(response).to have_http_status(200)
      expect(response.parsed_body["user"]["token"]).to eq("tok-1")
    end

    it "returns 401 for invalid credentials" do
      post "/login", params: { user: { username: "ghost", password: "x" } }, as: :json
      expect(response).to have_http_status(401)
    end
  end
end
