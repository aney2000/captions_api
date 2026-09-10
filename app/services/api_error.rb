module ApiError
  module_function

  def missing_parameter(param)
    {
      code: "missing_parameters",
      title: "Parameter is missing from the request body",
      description: "#{param} parameter is missing from the request body. " \
                   "It is a required parameter and the request cannot be processed without it"
    }
  end

  def invalid_parameter(param, reason = "is invalid")
    {
      code: "invalid_parameter",
      title: "Parameter value is invalid",
      description: "#{param} parameter #{reason}"
    }
  end

  def not_found(resource, id)
    {
      code: "not_found",
      title: "Resource not found",
      description: "#{resource} with id #{id} could not be found"
    }
  end
end
