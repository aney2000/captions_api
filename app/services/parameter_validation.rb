# Translates value-object validation errors into ServiceResult failures with
# the correct HTTP status: a missing parameter is a 400, any other invalid
# value is a 422. Shared by the caption creation services.
module ParameterValidation
  REASONS = {
    blank: "must not be empty",
    empty: "must not be empty",
    too_long: "is too long",
    not_http: "must be an http(s) URL",
    malformed: "is malformed",
    unsupported: "is not supported",
    unsupported_extension: "must be a jpg, jpeg or png image",
    invalid_type: "has an invalid type"
  }.freeze

  private

  # Returns a failure ServiceResult when the value object is invalid, else nil,
  # so validations can be composed with `||` into a readable guard chain.
  def validation_error(param, value_object)
    return nil if value_object.valid?

    failure_for(param, value_object)
  end

  def failure_for(param, value_object)
    if value_object.error == :missing
      ServiceResult.failure(error: ApiError.missing_parameter(param), status: 400)
    else
      ServiceResult.failure(
        error: ApiError.invalid_parameter(param, reason_for(value_object.error)),
        status: 422
      )
    end
  end

  def reason_for(error)
    REASONS.fetch(error, "is invalid")
  end
end
