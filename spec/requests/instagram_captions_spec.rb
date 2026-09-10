require "rails_helper"

RSpec.describe "Instagram Captions", type: :request do
  # Stub the image pipeline so no real download/generation/ImageMagick runs.
  before do
    allow_any_instance_of(ImageDownloader).to receive(:download) do |_i, url:, filename:|
      "/tmp/#{filename}"
    end
    allow_any_instance_of(ImageProcessor).to receive(:resize) { |_i, path:, **| path }
    allow_any_instance_of(ImageProcessor).to receive(:add_text) { |_i, path:, **| path }
    allow_any_instance_of(BackgroundGenerator).to receive(:solid) { |_i, path:, **| path }
    allow_any_instance_of(BackgroundGenerator).to receive(:gradient) { |_i, path:, **| path }
  end

  describe "POST /captions/instagram" do
    it "creates an image caption and returns 303 with a Location header" do
      post "/captions/instagram", params: {
        image: { type: "image", url: "http://example.com/a.jpg", text: "hi" }
      }, as: :json

      expect(response).to have_http_status(303)
      caption_url = response.parsed_body["caption"]["caption_url"]
      expect(caption_url).to start_with("http://www.example.com/images/")
      expect(response.headers["Location"]).to eq(caption_url)
      expect(response.parsed_body["caption"]["type"]).to eq("image")
    end

    it "creates a color caption and returns 303" do
      post "/captions/instagram", params: {
        image: { type: "color", color: "#003166", text: "hi" }
      }, as: :json

      expect(response).to have_http_status(303)
      expect(response.parsed_body["caption"]["type"]).to eq("color")
    end

    it "returns 400 when type is missing" do
      post "/captions/instagram", params: { image: { text: "hi" } }, as: :json

      expect(response).to have_http_status(400)
      expect(response.parsed_body["code"]).to eq("missing_parameters")
    end

    it "returns 422 when the image url is invalid" do
      post "/captions/instagram", params: {
        image: { type: "image", url: "http://example.com/a.gif", text: "hi" }
      }, as: :json

      expect(response).to have_http_status(422)
    end
  end

  describe "GET /captions/instagrams" do
    it "returns 200 and an empty array when none exist" do
      get "/captions/instagrams"

      expect(response).to have_http_status(200)
      expect(response.parsed_body).to eq("captions" => [])
    end

    it "returns all instagram captions" do
      create(:instagram_caption)
      get "/captions/instagrams"

      expect(response.parsed_body["captions"].size).to eq(1)
    end
  end
end
