class ImageStore
  def initialize(dir: Rails.root.join("public", "images").to_s, host: "http://localhost:3000")
    @dir = dir
    @host = host.chomp("/")
  end

  attr_reader :dir

  def public_url(filename)
    "#{@host}/images/#{filename}"
  end

  def path_for(filename)
    File.join(@dir, filename)
  end
end
