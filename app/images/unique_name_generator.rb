require "digest"

class UniqueNameGenerator
  def initialize(extension: "jpg")
    @extension = extension.to_s.delete_prefix(".")
  end

  def generate(url:, text:)
    digest = Digest::SHA256.hexdigest("#{url}|#{text}")
    "#{digest}.#{@extension}"
  end
end
