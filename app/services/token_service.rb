class TokenService
    def self.encode(user_id)
      payload = { user_id: user_id }
      JWT.encode(payload, ENV['TOKEN_PRIVATE_KEY'])
    end
  
    def self.decode(token)
      decoded = JWT.decode(token, ENV['TOKEN_PRIVATE_KEY'])[0]
      decoded['user_id']
    rescue JWT::DecodeError
      nil
    end
  end
  