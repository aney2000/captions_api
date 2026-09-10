class CreateCaption
  include ParameterValidation

  def initialize(store: ImageStore.new,
                 namer: UniqueNameGenerator.new,
                 downloader: nil,
                 processor: ImageProcessor.new,
                 caption_model: Caption)
    @store = store
    @namer = namer
    @downloader = downloader || ImageDownloader.new(dir: store.dir)
    @processor = processor
    @caption_model = caption_model
  end

  def call(url:, text:)
    url_vo = ImageUrl.new(url)
    text_vo = CaptionText.new(text)

    invalid = first_invalid(url: url_vo, text: text_vo)
    return invalid if invalid

    filename = @namer.generate(url: url, text: text)
    local_path = @downloader.download(url: url, filename: filename)
    @processor.add_text(path: local_path, text: text)

    caption = @caption_model.create!(
      url: url, text: text, caption_url: @store.public_url(filename)
    )
    ServiceResult.success(payload: serialize(caption), status: 201)
  end

  private

  def first_invalid(url:, text:)
    return failure_for("url", url) unless url.valid?
    return failure_for("text", text) unless text.valid?

    nil
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
