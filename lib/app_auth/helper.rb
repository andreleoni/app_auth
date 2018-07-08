module AppAuth::Helper
  def code
    @request.params['code']
  end

  def access_token
    @request.cookies['access_token']
  end

  def refresh_token
    @request.cookies['refresh_token']
  end

  def id_token
    @request.cookies['id_token']
  end

  def signed_in?
    code.present? ||
    access_token.present? ||
    refresh_token.present?
  end

  def redirect(location)
    [301, { 'Location' => location, 'Content-Type' => 'text/html' }]
  end

  def login_url
    "#{AppAuth.config.base_uri}/login?response_type=code&client_id=#{AppAuth.config.client_id}&redirect_uri=#{AppAuth.config.redirect_uri}&state=#{@request.url}"
  end

  def authorize_url
    "#{AppAuth.config.base_uri}/oauth2/token"
  end

  def authorize_body
    {
      grant_type: 'authorization_code',
      client_id: AppAuth.config.client_id,
      redirect_uri: AppAuth.config.redirect_uri,
      code: code
    }
  end

  def refresh_token_body
    {
      grant_type: 'refresh_token',
      client_id: AppAuth.config.client_id,
      refresh_token: refresh_token
    }
  end
end
