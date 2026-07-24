class ServiceResult
  attr_reader :status, :payload, :error

  def self.success(payload:, status: 200)
    new(success: true, status: status, payload: payload)
  end

  def self.failure(error:, status:)
    new(success: false, status: status, error: error)
  end

  def initialize(success:, status:, payload: nil, error: nil)
    @success = success
    @status = status
    @payload = payload
    @error = error
  end

  def success?
    @success
  end

  def failure?
    !@success
  end
end
