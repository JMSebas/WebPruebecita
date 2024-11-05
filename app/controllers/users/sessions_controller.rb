# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, options = {})
    token = request.env['warden-jwt_auth.token']
    response.set_cookie(:token, {
      value: token,
      httponly: true,
      secure: Rails.env.production?,
      expires: 24.hour.from_now
    })
    render json: {
      status: { code: 200, message: 'User signed in successfully', data: resource, access_token: token }
    }, status: :ok
  end

  def respond_to_on_destroy
    if request.headers['Authorization'].present?
      jwt_token = request.headers['Authorization'].split(' ')[1]
      response.delete_cookie(:token) # Eliminar cookie
      
      begin
        jwt_payload = JWT.decode(jwt_token, Rails.application.credentials.fetch(:secret_key_base), true, { algorithm: 'HS256' }).first
        current_user = User.find_by(id: jwt_payload['sub'])
  
        if current_user
          sign_out current_user 
          render json: {
            status: { code: 200, message: 'Signed out successfully' }
          }, status: :ok
        else
          render json: {
            status: { code: 401, message: 'User has no active session' }
          }, status: :unauthorized
        end
      rescue JWT::DecodeError
        render json: {
          status: { code: 401, message: 'Invalid token: Unable to decode' }
        }, status: :unauthorized
      end
    else
      render json: {
        status: { code: 401, message: 'Authorization header missing' }
      }, status: :unauthorized
    end
  end
end
