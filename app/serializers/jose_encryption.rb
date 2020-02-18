require 'jose'

class JoseEncryption
  def self.encrypt_attributes(model_attributes)
    encrypted = model_attributes.map do |attr_name, value|
      jsonify = JSON.generate(value)
      key_token = ENV["#{attr_name}_key"]

      if key_token
        jwk = JOSE::JWK.from_oct(key_token)

        cipher_text = jwk.block_encrypt(jsonify, {
          'zip' => 'DEF',
          'p2c' => 4096,
          'enc' => 'A128GCM',
          'alg' => 'PBES2-HS256+A128KW'
        }).compact

        [attr_name, cipher_text]
      else
        [attr_name, value]
      end
    end

    encrypted.to_h
  end

  def self.decrypt_cipher(attr_name, cipher_text)
    key = Rails.application.credentials.send(:"#{attr_name}_key")
    jwk = JOSE::JWK.from_oct(key)
    plain_text = jwk.block_decrypt(cipher_text)

    JSON.parse(plain_text[0])
  end

  def self.encrypt_attribute(attr_name, value)
    key = Rails.application.credentials.send(:"#{attr_name}_key")
    return value  unless key

    jsonify = JSON.generate(value)
    jwk = JOSE::JWK.from_oct(key)

    cipher_text = jwk.block_encrypt(jsonify, {
      'p2c' => 4096,
      'alg' => 'PBES2-HS256+A128KW',
      'enc' => 'A128GCM'
    }).compact
  end
end
