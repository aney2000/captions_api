require "rails_helper"

RSpec.describe Backgrounds::Catalog do
  subject(:catalog) do
    described_class.new(
      downloader: instance_double(ImageDownloader),
      processor: instance_double(ImageProcessor),
      generator: instance_double(BackgroundGenerator),
      store: instance_double(ImageStore),
      width: 1080,
      height: 1080
    )
  end

  it "returns the image source for the image type" do
    expect(catalog.for_type("image")).to be_a(Backgrounds::ImageSource)
  end

  it "returns the color source for the color type" do
    expect(catalog.for_type("color")).to be_a(Backgrounds::ColorSource)
  end

  it "returns the gradient source for the gradient type" do
    expect(catalog.for_type("gradient")).to be_a(Backgrounds::GradientSource)
  end

  it "raises for an unknown type" do
    expect { catalog.for_type("nope") }.to raise_error(KeyError)
  end
end
