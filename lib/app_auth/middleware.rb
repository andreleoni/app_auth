require 'rest-client'
require 'app_auth/helper'

class AppAuth::Middleware
  include AppAuth::Helper

  def initialize(app)
    @app = app
  end

  def call(env)
    @request = Rack::Request.new(env)
    return redirect(login_url) unless signed_in?

    @status, @headers, @body = @app.call(env)
    @response = Rack::Response.new(@body, @status, @headers)

    set_access_token_cookie
    set_id_token_cookie
    set_refresh_token_cookie

    set_user_attributes

    @response.finish
  end

  private

  def set_user_attributes
    AppAuth::User.access(access_token || authorize_user['access_token'])
    AppAuth::User.current(id_token || authorize_user['id_token'])
  end

  def set_refresh_token_cookie
    return if refresh_token.present?

    @response.set_cookie('refresh_token', { value: authorize_user['refresh_token'], expires: 15.days.from_now })

    # @response.set_cookie('refresh_token', { value: authorize_user['refresh_token'], expires: 15.days.from_now, domain: 'sidekiq.enjoei.com.br' })
  end

  def set_access_token_cookie
    return if access_token.present?

    @response.set_cookie('access_token', { value: authorize_user['access_token'], expires: 20.seconds.from_now })

    # @response.set_cookie('access_token', { value: authorize_user['access_token'], expires: 20.seconds.from_now, domain: 'sidekiq.enjoei.com.br' })
  end

  def set_id_token_cookie
    return if id_token.present?

    @response.set_cookie('id_token', { value: authorize_user['id_token'], expires: 20.seconds.from_now })

    # @response.set_cookie('id_token', { value: authorize_user['id_token'], expires: 20.seconds.from_now, domain: 'sidekiq.enjoei.com.br' })
  end

  def authorize_user
    @authorize_user ||=
      if refresh_token.blank?
        JSON.parse(RestClient.post(authorize_url, authorize_body))
      elsif refresh_token.present?
        JSON.parse(RestClient.post(authorize_url, refresh_token_body))
      else
        {}
      end
  rescue
    {}
  end
end
