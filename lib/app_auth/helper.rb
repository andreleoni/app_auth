module AppAuth::Helper
  def could_redirect?
    code.blank? && refresh_token.blank?
  end

  def redirect(location)
    [302, { 'Location' => location, 'Content-Type' => 'text/html' }, ['Move to auth page']]
  end

  def login_url
    "#{AppAuth.config.federate_base_uri}/login?response_type=code&client_id=#{AppAuth.config.client_id}&redirect_uri=#{redirect_uri}&state=#{@request.url}"
  end

  def authorize_url
    "#{AppAuth.config.federate_base_uri}/oauth2/token"
  end

  def authorize_body
    {
      grant_type: 'authorization_code',
      client_id: AppAuth.config.client_id,
      redirect_uri: redirect_uri,
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

  def redirect_uri
    "#{actual_uri}#{AppAuth.config.app_redirect_path}"
  end

  def actual_uri
    return development_uri if Rails.env.development?
    @request.url.match(url_regex)[0]
  end

  def development_uri
    protocol, url = @request.url.match(url_regex)[0].split('//')
    "https://#{url}"
  end

  def url_regex
    'https?:\/\/[\S][\w.]+(:\d+)?'
  end
end
