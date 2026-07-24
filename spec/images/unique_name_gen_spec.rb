require "rails_helper"

RSpec.describe UniqueNameGenerator do
  subject(:generator) { described_class.new }

  it "produces a .jpg filename by default" do
    name = generator.generate(url: "http://x.com/a.jpg", text: "hi")
    expect(name).to end_with(".jpg")
  end

  it "is deterministic for the same url and text" do
    a = generator.generate(url: "http://x.com/a.jpg", text: "hi")
    b = generator.generate(url: "http://x.com/a.jpg", text: "hi")
    expect(a).to eq(b)
  end

  it "differs when the text differs for the same url" do
    a = generator.generate(url: "http://x.com/a.jpg", text: "hi")
    b = generator.generate(url: "http://x.com/a.jpg", text: "bye")
    expect(a).not_to eq(b)
  end

  it "differs when the url differs for the same text" do
    a = generator.generate(url: "http://x.com/a.jpg", text: "hi")
    b = generator.generate(url: "http://y.com/a.jpg", text: "hi")
    expect(a).not_to eq(b)
  end

  it "honors a custom extension" do
    name = described_class.new(extension: "png").generate(url: "u", text: "t")
    expect(name).to end_with(".png")
  end
end
