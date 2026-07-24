class SignupUser
  def initialize(hasher: PasswordHasher.new, token_generator: TokenGenerator.new, user_model: User)
    @hasher = hasher
    @token_generator = token_generator
    @user_model = user_model
  end

  def call(username:, password:)
    return blank_error("username") if blank?(username)
    return blank_error("password") if blank?(password)
    return conflict if @user_model.exists?(username: username)

    user = @user_model.create!(
      username: username,
      password_digest: @hasher.hash(password),
      token: @token_generator.generate
    )
    ServiceResult.success(payload: { token: user.token }, status: 201)
  rescue ActiveRecord::RecordNotUnique
    conflict
  end

  private

  def blank?(value)
    value.nil? || value.to_s.strip.empty?
  end

  def blank_error(field)
    ServiceResult.failure(error: ApiError.missing_parameter(field), status: 400)
  end

  def conflict
    ServiceResult.failure(error: ApiError.conflict("User"), status: 409)
  end
end
