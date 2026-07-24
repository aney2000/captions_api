require "bcrypt"

class PasswordHasher
  def hash(plain)
    BCrypt::Password.create(plain).to_s
  end

  def verify(plain, digest)
    return false if digest.nil? || digest.to_s.empty?

    BCrypt::Password.new(digest) == plain
  rescue BCrypt::Errors::InvalidHash
    false
  end
end
