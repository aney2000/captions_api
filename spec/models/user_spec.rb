require "rails_helper"

RSpec.describe User do
  subject { build(:user) }

  it { is_expected.to validate_presence_of(:username) }
  it { is_expected.to validate_uniqueness_of(:username) }
  it { is_expected.to validate_presence_of(:password_digest) }
  it { is_expected.to validate_presence_of(:token) }
  it { is_expected.to validate_uniqueness_of(:token) }

  it "is valid with the factory defaults" do
    expect(build(:user)).to be_valid
  end
end
