module AppAuth::Cookies
  def code
    @request.params['code']
  end

  def access_token
    token = @request.cookies['auth_attributes']
    return nil if token.blank?
    JSON.parse(decrypt(token))['access_token']
  end

  def refresh_token
    token = @request.cookies['auth_token']
    return nil if token.blank?
    decrypt(token)
  end

  def id_token
    token = @request.cookies['auth_attributes']
    return nil if token.blank?
    JSON.parse(decrypt(token))['id_token']
  end

  def set_auth_cookies
    return if refresh_token.present?

    @response.set_cookie(
      'auth_token',
      {
        value: encrypt(authorize_user['refresh_token']),
        expires: 15.days.from_now
      })
  end

  def set_attributes_cookies
    return if access_token.present? && id_token.present?

    @response.set_cookie(
      'auth_attributes',
      {
        value: encrypt(
          JSON.generate(authorize_user.slice('access_token', 'id_token'))
        ),
        expires: 10.seconds.from_now
      })
  end
end
