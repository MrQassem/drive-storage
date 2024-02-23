class ApplicationController < ActionController::Base
    before_action :authenticate_request

    private
  
    def authenticate_request
      token = request.headers['Authorization']&.split(' ')&.last
      user_id = TokenService.decode(token)
      render json: { error: 'Unauthorized' }, status: :unauthorized unless user_id
    end
end
