require "rails_helper"

RSpec.describe ParameterValidation do
  # Minimal host that exposes the shared, otherwise-private behavior.
  let(:host) do
    Class.new do
      include ParameterValidation

      def failure(param, value_object)
        failure_for(param, value_object)
      end

      def error(param, value_object)
        validation_error(param, value_object)
      end
    end.new
  end

  it "maps a :missing error to a 400 missing_parameters failure" do
    result = host.failure("url", double(error: :missing))

    expect(result.status).to eq(400)
    expect(result.error[:code]).to eq("missing_parameters")
  end

  it "maps other errors to a 422 invalid_parameter failure with a reason" do
    result = host.failure("url", double(error: :blank))

    expect(result.status).to eq(422)
    expect(result.error[:code]).to eq("invalid_parameter")
    expect(result.error[:description]).to include("must not be empty")
  end

  it "falls back to a generic reason for unknown error symbols" do
    result = host.failure("url", double(error: :something_else))

    expect(result.error[:description]).to include("is invalid")
  end

  describe "#validation_error" do
    it "returns nil for a valid value object" do
      expect(host.error("url", double(valid?: true))).to be_nil
    end

    it "returns a failure for an invalid value object" do
      result = host.error("url", double(valid?: false, error: :blank))

      expect(result.status).to eq(422)
      expect(result.error[:code]).to eq("invalid_parameter")
    end
  end
end
