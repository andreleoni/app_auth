require 'openssl'

module AppAuth::Secure
  def encrypt(text)
    text = text.to_s
    salt = SecureRandom.hex(len)
    encrypted_data = crypt(salt).encrypt_and_sign(text)
    "#{salt}#{split_string}#{encrypted_data}"
  end

  def decrypt(text)
    salt, data = text.to_s.split(split_string)
    crypt(salt).decrypt_and_verify(data)
  end

  def encrypt_key
    AppAuth.config.encrypt_cookie_key
  end

  def crypt(salt)
    key = ActiveSupport::KeyGenerator.new(encrypt_key).generate_key(salt, len)
    ActiveSupport::MessageEncryptor.new(key)
  end

  def len
    ActiveSupport::MessageEncryptor.key_len
  end

  def split_string
    '$$'
  end
end
