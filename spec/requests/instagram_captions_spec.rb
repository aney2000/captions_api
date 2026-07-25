require "rails_helper"

RSpec.describe "Instagram Captions", type: :request do
  before do
    allow_any_instance_of(ImageDownloader).to receive(:download) do |_i, url:, filename:|
      "/tmp/#{filename}"
    end
    allow_any_instance_of(ImageProcessor).to receive(:resize) { |_i, path:, **| path }
    allow_any_instance_of(ImageProcessor).to receive(:add_text) { |_i, path:, **| path }
    # Avoid real ImageMagick canvas creation for color/gradient.
    allow_any_instance_of(Backgrounds::ColorBackground).to receive(:generate) do |_i, path_dir:, filename:, **|
      File.join(path_dir, filename)
    end
    allow_any_instance_of(Backgrounds::GradientBackground).to receive(:generate) do |_i, path_dir:, filename:, **|
      File.join(path_dir, filename)
    end
  end

  describe "POST /captions/instagram" do
    it "creates an image-type caption with 303 + Location header" do
      post "/captions/instagram",
        params: { image: { type: "image", url: "http://example.com/a.jpg", text: "hi" } }, as: :json

      expect(response).to have_http_status(303)
      expect(response.headers["Location"]).to be_present
      expect(response.parsed_body["caption"]["type"]).to eq("image")
    end

    it "creates a color-type caption" do
      post "/captions/instagram",
        params: { image: { type: "color", color: "#003166", text: "hi" } }, as: :json
      expect(response).to have_http_status(303)
      expect(response.parsed_body["caption"]["type"]).to eq("color")
    end

    it "creates a gradient-type caption" do
      post "/captions/instagram",
        params: { image: { type: "gradient", start_color: "#000000", end_color: "#003166", text: "hi" } }, as: :json
      expect(response).to have_http_status(303)
    end

    it "422s for an unsupported filter" do
      post "/captions/instagram",
        params: { image: { type: "image", url: "http://example.com/a.jpg", text: "hi", filter: ["sepia"] } }, as: :json
      expect(response).to have_http_status(422)
    end

    it "422s when a filter is used with a color background" do
      post "/captions/instagram",
        params: { image: { type: "color", color: "#003166", text: "hi", filter: ["blackwhite"] } }, as: :json
      expect(response).to have_http_status(422)
    end

    it "400s when type is missing" do
      post "/captions/instagram", params: { image: { text: "hi" } }, as: :json
      expect(response).to have_http_status(400)
    end
  end

  describe "GET /captions/instagram" do
    it "returns 200 and a list" do
      create(:instagram_caption)
      get "/captions/instagram"
      expect(response).to have_http_status(200)
      expect(response.parsed_body["captions"].size).to eq(1)
    end
  end
end
