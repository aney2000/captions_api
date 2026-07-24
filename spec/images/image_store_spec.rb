require "rails_helper"

RSpec.describe ImageStore do
  subject(:store) { described_class.new(dir: "/data/images", host: "http://example.com") }

  it "builds a public url under /images" do
    expect(store.public_url("a.jpg")).to eq("http://example.com/images/a.jpg")
  end

  it "strips a trailing slash from the host" do
    s = described_class.new(dir: "/d", host: "http://example.com/")
    expect(s.public_url("a.jpg")).to eq("http://example.com/images/a.jpg")
  end

  it "builds an on-disk path" do
    expect(store.path_for("a.jpg")).to eq("/data/images/a.jpg")
  end
end
