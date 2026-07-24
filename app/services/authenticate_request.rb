class AuthenticateRequest
  BEARER = /\ABearer\s+(.+)\z/i

  def initialize(user_model: User)
    @user_model = user_model
  end

  def call(authorization_header)
    token = extract_token(authorization_header)
    return unauthorized if token.nil?

    user = @user_model.find_by(token: token)
    return unauthorized if user.nil?

    ServiceResult.success(payload: user, status: 200)
  end

  private

  def extract_token(header)
    return nil if header.nil?

    match = BEARER.match(header.to_s)
    match && match[1].strip
  end

  def unauthorized
    ServiceResult.failure(error: ApiError.unauthorized, status: 401)
  end
end
