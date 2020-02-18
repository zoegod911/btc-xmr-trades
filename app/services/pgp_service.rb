require 'faraday'
require 'faker'
if Rails.env.production?
  require 'faraday_middleware'
  require 'faraday_adapter_socks'
end

class PgpService

  def self.generate_trade_chat(trade_id:, passphrase:)
    trade_chat = TradeChat.new(trade_id: trade_id, passphrase: passphrase)
    @trade = trade_chat.trade

    user_ids = [
      { name: @trade.buyer.username, email: Faker::Internet.unique.email },
      { name: @trade.seller.username, email: Faker::Internet.unique.email }
    ]

    url = "http://#{PAYMENT_API}/pgp/generate_chat_keys"

    opts = {
      url: url, request: { timeout: 10000, open_timeout: 10000 },
    }

    conn = Faraday.new(opts)

    post_data = { passphrase: passphrase, user_ids: user_ids.to_json }

    res = conn.post('/api/v1/pgp/generate_chat_keys', post_data).body

    keys = parse_response(res)

    trade_chat.pgp_public_key   = keys.pubkey
    trade_chat.pgp_private_key  = keys.privkey
    trade_chat.save!
  end



  private

  def self.parse_response(response)
    response = JSON.parse(response, object_class: OpenStruct)
    response.status == 'success' ? response.data : false
  end
end
