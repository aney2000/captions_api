require "rails_helper"

RSpec.describe DeleteCaption do
  let(:store) { ImageStore.new(dir: Dir.mktmpdir, host: "http://test.host") }
  subject(:service) { described_class.new(store: store) }

  it "deletes the caption and its file, returning 200" do
    filename = "gen.jpg"
    File.write(store.path_for(filename), "bytes")
    caption = create(:caption, caption_url: store.public_url(filename))

    result = service.call(id: caption.id)

    expect(result.status).to eq(200)
    expect(Caption.exists?(caption.id)).to be(false)
    expect(File.exist?(store.path_for(filename))).to be(false)
  end

  it "returns 404 when the caption does not exist" do
    result = service.call(id: 999_999)
    expect(result.status).to eq(404)
    expect(result.error[:code]).to eq("not_found")
  end
end
