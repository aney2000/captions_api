require "fileutils"

class DeleteCaption
  def initialize(store: ImageStore.new, caption_model: Caption)
    @store = store
    @caption_model = caption_model
  end

  def call(id:)
    caption = @caption_model.find_by(id: id)
    return not_found(id) if caption.nil?

    delete_file(caption.caption_url)
    caption.destroy!
    ServiceResult.success(payload: {}, status: 200)
  end

  private

  def delete_file(caption_url)
    filename = File.basename(URI.parse(caption_url).path)
    path = @store.path_for(filename)
    FileUtils.rm_f(path)
  rescue URI::InvalidURIError
    nil
  end

  def not_found(id)
    ServiceResult.failure(error: ApiError.not_found("Caption", id), status: 404)
  end
end
