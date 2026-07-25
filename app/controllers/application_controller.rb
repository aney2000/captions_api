class ApplicationController < ActionController::API
  def render_result(result, success_status: nil)
    if result.success?
      render json: result.payload, status: (success_status || result.status)
    else
      render json: result.error, status: result.status
    end
  end
end
