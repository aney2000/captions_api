require "rails_helper"

RSpec.describe TokenGenerator do
  subject(:generator) { described_class.new }

  it "generates a 32-character hex token" do
    token = generator.generate
    expect(token).to match(/\A\h{32}\z/)
  end

  it "generates a different token each call" do
    expect(generator.generate).not_to eq(generator.generate)
  end
end
