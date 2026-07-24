require "securerandom"

class TokenGenerator
  def generate
    SecureRandom.hex(16)
  end
end
