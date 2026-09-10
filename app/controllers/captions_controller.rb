class CaptionsController < ApplicationController
  def index
    captions = Caption.all.map { |c| serialize(c) }
    render json: { captions: captions }, status: 200
  end

  def show
    caption = Caption.find_by(id: params[:id])
    return render json: ApiError.not_found("Caption", params[:id]), status: 404 if caption.nil?

    render json: { caption: serialize(caption) }, status: 200
  end

  def create
    attrs = caption_params
    result = CreateCaption.new(store: image_store).call(url: attrs[:url], text: attrs[:text])
    if result.success?
      render json: { caption: result.payload }, status: 201
    else
      render json: result.error, status: result.status
    end
  end

  def destroy
    result = DeleteCaption.new.call(id: params[:id])
    render_result(result)
  end

  private

  def caption_params
    body = params[:caption] || {}
    { url: body[:url], text: body[:text] }
  end

  def serialize(caption)
    {
      id: caption.id,
      url: caption.url,
      text: caption.text,
      caption_url: caption.caption_url
    }
  end
end
