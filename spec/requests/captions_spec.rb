require "rails_helper"

RSpec.describe "Captions", type: :request do
  # Stub the image pipeline so no real download/ImageMagick runs.
  before do
    allow_any_instance_of(ImageDownloader).to receive(:download) do |_i, url:, filename:|
      "/tmp/#{filename}"
    end
    allow_any_instance_of(ImageProcessor).to receive(:add_text) { |_i, path:, **| path }
  end

  describe "GET /captions" do
    it "returns 200 and an empty array when none exist" do
      get "/captions"
      expect(response).to have_http_status(200)
      expect(response.parsed_body).to eq("captions" => [])
    end

    it "returns all captions" do
      create(:caption)
      get "/captions"
      expect(response.parsed_body["captions"].size).to eq(1)
    end
  end

  describe "POST /captions" do
    it "creates a caption and returns 201" do
      post "/captions", params: { caption: { url: "http://example.com/a.jpg", text: "hi" } }, as: :json

      expect(response).to have_http_status(201)
      expect(response.parsed_body["caption"]["text"]).to eq("hi")
      expect(response.parsed_body["caption"]["caption_url"]).to be_present
    end

    it "returns 400 when url is missing" do
      post "/captions", params: { caption: { text: "hi" } }, as: :json
      expect(response).to have_http_status(400)
      expect(response.parsed_body["code"]).to eq("missing_parameters")
    end

    it "returns 422 when url value is empty" do
      post "/captions", params: { caption: { url: "", text: "hi" } }, as: :json
      expect(response).to have_http_status(422)
    end
  end

  describe "GET /captions/:id" do
    it "returns the caption" do
      caption = create(:caption)
      get "/captions/#{caption.id}"
      expect(response).to have_http_status(200)
      expect(response.parsed_body["caption"]["id"]).to eq(caption.id)
    end

    it "returns the stored caption_url, not the original url" do
      caption = create(:caption, url: "http://example.com/a.jpg",
                                 caption_url: "http://localhost/images/generated.jpg")
      get "/captions/#{caption.id}"

      expect(response.parsed_body["caption"]["url"]).to eq("http://example.com/a.jpg")
      expect(response.parsed_body["caption"]["caption_url"]).to eq("http://localhost/images/generated.jpg")
    end

    it "returns 404 when not found" do
      get "/captions/999999"
      expect(response).to have_http_status(404)
      expect(response.parsed_body["code"]).to eq("not_found")
    end
  end

  describe "DELETE /captions/:id" do
    it "deletes and returns 200" do
      caption = create(:caption)
      delete "/captions/#{caption.id}"
      expect(response).to have_http_status(200)
      expect(Caption.exists?(caption.id)).to be(false)
    end

    it "returns 404 when not found" do
      delete "/captions/999999"
      expect(response).to have_http_status(404)
    end
  end
end
