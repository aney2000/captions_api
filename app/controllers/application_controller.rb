class ApplicationController < ActionController::API
  def render_result(result, success_status: nil)
    if result.success?
      render json: result.payload, status: (success_status || result.status)
    else
      render json: result.error, status: result.status
    end
  end

  private

  # An image store whose public URLs are built from the current request host,
  # so generated caption_urls point back at this running server.
  def image_store
    ImageStore.new(host: request.base_url)
  end
end
