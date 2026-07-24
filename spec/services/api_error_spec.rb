require "rails_helper"

RSpec.describe ApiError do
  it "builds a missing_parameter error mentioning the param" do
    err = described_class.missing_parameter("url")
    expect(err[:code]).to eq("missing_parameters")
    expect(err[:description]).to include("url")
  end

  it "builds an invalid_parameter error with a reason" do
    err = described_class.invalid_parameter("url", "must not be empty")
    expect(err[:code]).to eq("invalid_parameter")
    expect(err[:description]).to include("url")
    expect(err[:description]).to include("must not be empty")
  end

  it "builds a not_found error mentioning the resource and id" do
    err = described_class.not_found("Caption", 7)
    expect(err[:code]).to eq("not_found")
    expect(err[:description]).to include("Caption")
    expect(err[:description]).to include("7")
  end

  it "builds an unauthorized error" do
    expect(described_class.unauthorized[:code]).to eq("unauthorized")
  end

  it "builds a conflict error" do
    expect(described_class.conflict("User")[:code]).to eq("conflict")
  end
end
