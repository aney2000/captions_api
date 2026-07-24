class CreateMeme
  def initialize(store: ImageStore.new,
                 namer: UniqueNameGenerator.new,
                 downloader: nil,
                 processor: ImageProcessor.new)
    @store = store
    @namer = namer
    @downloader = downloader || ImageDownloader.new(dir: store.dir)
    @processor = processor
  end

  def call(image_url:, text:)
    url_vo = ImageUrl.new(image_url)
    text_vo = CaptionText.new(text)
    return failure("image_url", url_vo) unless url_vo.valid?
    return failure("text", text_vo) unless text_vo.valid?

    filename = @namer.generate(url: image_url, text: text)
    local_path = @downloader.download(url: image_url, filename: filename)
    @processor.add_text(path: local_path, text: text)

    ServiceResult.success(payload: { caption_url: @store.public_url(filename) }, status: 303)
  end

  private

  def failure(param, vo)
    status = vo.error == :missing ? 400 : 422
    error = vo.error == :missing ? ApiError.missing_parameter(param) : ApiError.invalid_parameter(param)
    ServiceResult.failure(error: error, status: status)
  end
end
