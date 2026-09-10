class CreateInstagramCaption
  include ParameterValidation

  WIDTH = 1080
  HEIGHT = 1080

  def initialize(store: ImageStore.new,
                 namer: UniqueNameGenerator.new,
                 downloader: nil,
                 processor: ImageProcessor.new,
                 generator: BackgroundGenerator.new,
                 catalog: nil,
                 caption_model: InstagramCaption)
    @store = store
    @namer = namer
    @processor = processor
    @caption_model = caption_model
    @catalog = catalog || build_catalog(downloader || ImageDownloader.new(dir: store.dir), generator)
  end

  def call(type:, text:, url: nil, color: nil, start_color: nil, end_color: nil, filter: nil)
    type_vo = ImageType.new(type)
    text_vo = CaptionText.new(text)
    filter_vo = FilterList.new(filter)
    attrs = { url: url, color: color, start_color: start_color, end_color: end_color }

    invalid = validate(type_vo, text_vo, filter_vo, attrs)
    return invalid if invalid

    generate(type_vo, text_vo, filter_vo, attrs)
  end

  private

  def build_catalog(downloader, generator)
    Backgrounds::Catalog.new(
      downloader: downloader, processor: @processor, generator: generator,
      store: @store, width: WIDTH, height: HEIGHT
    )
  end

  def generate(type_vo, text_vo, filter_vo, attrs)
    text = text_vo.value
    filename = @namer.generate(url: seed_for(type_vo, attrs), text: text)
    path = @catalog.for_type(type_vo.value).build(filename: filename, attrs: attrs)

    apply_filters(filter_vo, path)
    @processor.add_text(path: path, text: text)

    caption = persist(type_vo, text, attrs[:url], filter_vo, filename)
    ServiceResult.success(payload: serialize(caption, filter_vo), status: 303)
  end

  def persist(type_vo, text, url, filter_vo, filename)
    @caption_model.create!(
      type_name: type_vo.value,
      text: text,
      url: url,
      filter: filter_vo.present? ? filter_vo.names.join(",") : nil,
      caption_url: @store.public_url(filename)
    )
  end

  def apply_filters(filter_vo, path)
    filter_vo.build.each { |filter| filter.apply(path) }
  end

  def seed_for(type_vo, attrs)
    return attrs[:url] if type_vo.image?
    return attrs[:color] if type_vo.color?

    "#{attrs[:start_color]}|#{attrs[:end_color]}"
  end

  def validate(type_vo, text_vo, filter_vo, attrs)
    validation_error("type", type_vo) ||
      validation_error("text", text_vo) ||
      validation_error("filter", filter_vo) ||
      filters_guard(filter_vo, type_vo) ||
      validate_background(type_vo, attrs)
  end

  def filters_guard(filter_vo, type_vo)
    filters_not_allowed if filter_vo.present? && !type_vo.image?
  end

  def validate_background(type_vo, attrs)
    return validation_error("url", ImageUrl.new(attrs[:url])) if type_vo.image?
    return validation_error("color", HexColor.new(attrs[:color])) if type_vo.color?

    validate_gradient(attrs)
  end

  def validate_gradient(attrs)
    validation_error("start_color", HexColor.new(attrs[:start_color])) ||
      validation_error("end_color", HexColor.new(attrs[:end_color]))
  end

  def filters_not_allowed
    ServiceResult.failure(
      error: ApiError.invalid_parameter("filter", "is only allowed when type is image"),
      status: 422
    )
  end

  def serialize(caption, filter_vo)
    {
      id: caption.id,
      url: caption.url,
      type: caption.type,
      text: caption.text,
      filter: filter_vo.present? ? filter_vo.names : nil,
      caption_url: caption.caption_url
    }
  end
end
