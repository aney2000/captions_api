class UsersController < ApplicationController
  def signup
    attrs = user_params
    result = SignupUser.new.call(username: attrs[:username], password: attrs[:password])
    if result.success?
      render json: { user: result.payload }, status: 201
    else
      render json: result.error, status: result.status
    end
  end

  def login
    attrs = user_params
    result = LoginUser.new.call(username: attrs[:username], password: attrs[:password])
    if result.success?
      render json: { user: result.payload }, status: 200
    else
      render json: result.error, status: result.status
    end
  end

  private

  def user_params
    body = params[:user] || {}
    { username: body[:username], password: body[:password] }
  end
end
