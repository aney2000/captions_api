require "rails_helper"

RSpec.describe "Memes", type: :request do
  before do
    allow_any_instance_of(ImageDownloader).to receive(:download) do |_i, url:, filename:|
      "/tmp/#{filename}"
    end
    allow_any_instance_of(ImageProcessor).to receive(:add_text) { |_i, path:, **| path }
  end

  let!(:user) { create(:user, token: "valid-token") }

  describe "POST /memes" do
    it "redirects with 307 to the generated image when authenticated" do
      post "/memes",
        params: { meme: { image_url: "http://example.com/a.jpg", text: "hi" } },
        headers: { "Authorization" => "Bearer valid-token" }, as: :json

      expect(response).to have_http_status(307)
      expect(response.headers["Location"]).to be_present
    end

    it "returns 401 without an Authorization header" do
      post "/memes",
        params: { meme: { image_url: "http://example.com/a.jpg", text: "hi" } }, as: :json
      expect(response).to have_http_status(401)
    end

    it "returns 401 with an invalid token" do
      post "/memes",
        params: { meme: { image_url: "http://example.com/a.jpg", text: "hi" } },
        headers: { "Authorization" => "Bearer wrong" }, as: :json
      expect(response).to have_http_status(401)
    end
  end
end
