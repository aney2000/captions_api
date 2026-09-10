class InstagramCaptionsController < ApplicationController
  def index
    captions = InstagramCaption.all.map { |caption| serialize(caption) }
    render json: { captions: captions }, status: 200
  end

  def create
    result = CreateInstagramCaption.new(store: image_store).call(**instagram_params)
    if result.success?
      response.set_header("Location", result.payload[:caption_url])
      render json: { caption: result.payload }, status: result.status
    else
      render json: result.error, status: result.status
    end
  end

  private

  def instagram_params
    body = params[:image] || {}
    {
      type: body[:type],
      url: body[:url],
      text: body[:text],
      color: body[:color],
      start_color: body[:start_color],
      end_color: body[:end_color],
      filter: body[:filter]
    }
  end

  def serialize(caption)
    {
      id: caption.id,
      url: caption.url,
      type: caption.type,
      text: caption.text,
      filter: caption.filter.presence&.split(","),
      caption_url: caption.caption_url
    }
  end
end
