require 'faraday'

if Rails.env =='production'
  require 'faraday_middleware'
  require 'faraday_adapter_socks'
end

class PgpMessenger
  def self.encrypt_message(pgp_private_key: nil, pgp_public_key:, passphrase: nil, message:)
    url = "http://#{PAYMENT_API}/pgp/encrypt"

    conn = Faraday.new(url: url)

    post_data = {
      public_key: pgp_public_key,
      message: message
    }
    res = conn.post('/api/v1/pgp/encrypt', post_data).body

    valid = parse_response(res)

    valid ? JSON.parse(valid) : valid
  end

  def self.decrypt_message(pgp_private_key:, pgp_public_key:, passphrase:, pgp_message:)
    url = "http://#{PAYMENT_API}/pgp/decrypt"

    conn = Faraday.new(url: url)

    post_data = {
      public_key: pgp_public_key,
      private_key: pgp_private_key,
      passphrase: passphrase,
      cipher: pgp_message
    }

    res = conn.post('/api/v1/pgp/decrypt', post_data).body

    parse_response(res).data
  end

  private

  def self.parse_response(response)
    response = JSON.parse(response, object_class: OpenStruct)
    response.status == 'success' ? response.data : false
  end
end
