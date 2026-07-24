class MemesController < ApplicationController
  def create
    with_authenticated_user do |_user|
      attrs = meme_params
      result = CreateMeme.new.call(image_url: attrs[:image_url], text: attrs[:text])
      if result.success?
        redirect_to result.payload[:caption_url], status: 307, allow_other_host: true
      else
        render json: result.error, status: result.status
      end
    end
  end

  private

  def meme_params
    body = params[:meme] || {}
    { image_url: body[:image_url], text: body[:text] }
  end
end
