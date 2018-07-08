require 'jwt'

class AppAuth::User
  class << self
    def signed_in?
      current.present?
    end

    def current(id_token_jwt = nil)
      return {} if id_token_jwt.blank? && @current.blank?
      @current ||= JWT.decode(id_token_jwt, nil, false).flatten.first
    end

    def access(access_token_jwt = nil)
      return {} if access_token_jwt.blank? && @access.blank?
      @access ||= JWT.decode(access_token_jwt, nil, false).flatten.first
    end
  end
end
