class ApplicationController < ActionController::Base
    before_action :authenticate_request

    private
  
    def authenticate_request
      token = request.headers['Authorization']&.split(' ')&.last
      user_id = TokenService.decode(token)
      if user_id
        @current_user_id = user_id
      else
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end
end
