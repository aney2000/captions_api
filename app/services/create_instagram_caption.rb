class CreateInstagramCaption
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
    return failure_for("type", type_vo) unless type_vo.valid?
    return failure_for("text", text_vo) unless text_vo.valid?
    return failure_for("filter", filter_vo) unless filter_vo.valid?
    return filters_not_allowed if filter_vo.present? && !type_vo.image?

    validate_background(type_vo, attrs)
  end

  def validate_background(type_vo, attrs)
    return failure_for("url", ImageUrl.new(attrs[:url])) if type_vo.image? && !ImageUrl.new(attrs[:url]).valid?
    return failure_for("color", HexColor.new(attrs[:color])) if type_vo.color? && !HexColor.new(attrs[:color]).valid?
    return nil unless type_vo.gradient?

    validate_gradient(attrs)
  end

  def validate_gradient(attrs)
    start_vo = HexColor.new(attrs[:start_color])
    return failure_for("start_color", start_vo) unless start_vo.valid?

    end_vo = HexColor.new(attrs[:end_color])
    return failure_for("end_color", end_vo) unless end_vo.valid?

    nil
  end

  def filters_not_allowed
    ServiceResult.failure(
      error: ApiError.invalid_parameter("filter", "is only allowed when type is image"),
      status: 422
    )
  end

  def failure_for(param, value_object)
    if value_object.error == :missing
      ServiceResult.failure(error: ApiError.missing_parameter(param), status: 400)
    else
      ServiceResult.failure(
        error: ApiError.invalid_parameter(param, reason_for(value_object.error)),
        status: 422
      )
    end
  end

  def reason_for(error)
    {
      blank: "must not be empty",
      empty: "must not be empty",
      too_long: "is too long",
      not_http: "must be an http(s) URL",
      malformed: "is malformed",
      unsupported: "is not supported",
      unsupported_extension: "must be a jpg, jpeg or png image",
      invalid_type: "has an invalid type"
    }.fetch(error, "is invalid")
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
