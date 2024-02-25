require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe 'POST /generate_token' do
    let(:user_id) { '123' }

    it 'generates a token for the given user_id' do
      post '/generate_token', params: { user_id: user_id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key('token')
      token = JSON.parse(response.body)['token']

      # Decode the token to verify the payload
      decoded_token = TokenService.decode(token)
      expect(decoded_token).to eq(user_id)
    end
  end
end
