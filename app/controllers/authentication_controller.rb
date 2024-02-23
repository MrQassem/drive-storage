class AuthenticationController < ApplicationController
    skip_before_action :authenticate_request, only: [:generate_token]
    skip_before_action :verify_authenticity_token, only: [:generate_token]
    def generate_token
        user_id = params[:user_id]
        token = TokenService.encode(user_id)
        render json: { token: token }, status: :ok
    end
end