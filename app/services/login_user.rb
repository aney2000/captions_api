class LoginUser
  def initialize(hasher: PasswordHasher.new, user_model: User)
    @hasher = hasher
    @user_model = user_model
  end

  def call(username:, password:)
    return invalid if blank?(username) || blank?(password)

    user = @user_model.find_by(username: username)
    return invalid unless user && @hasher.verify(password, user.password_digest)

    ServiceResult.success(payload: { token: user.token }, status: 200)
  end

  private

  def blank?(value)
    value.nil? || value.to_s.strip.empty?
  end

  def invalid
    ServiceResult.failure(
      error: ApiError.invalid_parameter("credentials", "are invalid"),
      status: 401
    )
  end
end
