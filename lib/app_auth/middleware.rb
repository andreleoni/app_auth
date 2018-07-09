require 'rest-client'
require 'app_auth/helper'
require 'app_auth/secure'
require 'app_auth/cookies'

class AppAuth::Middleware
  include AppAuth::Helper
  include AppAuth::Secure
  include AppAuth::Cookies

  def initialize(app)
    @app = app
  end

  def call(env)
    @request = Rack::Request.new(env)
    return redirect(login_url) if could_redirect?

    @status, @headers, @body = @app.call(env)
    @response = Rack::Response.new(@body, @status, @headers)

    set_auth_cookies
    set_attributes_cookies
    set_user_attributes

    @response.finish
  end

  private

  def set_user_attributes
    AppAuth::User.access(access_token || authorize_user['access_token'])
    AppAuth::User.current(id_token || authorize_user['id_token'])
  end

  def authorize_user
    @authorize_user ||=
      if refresh_token.present?
        JSON.parse(RestClient.post(authorize_url, refresh_token_body))
      else
        JSON.parse(RestClient.post(authorize_url, authorize_body))
      end
  rescue
    {}
  end
end
