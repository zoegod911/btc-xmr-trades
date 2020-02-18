
require 'faraday'

if Rails.env.production?
  require 'faraday_middleware'
  require 'faraday_adapter_socks'
end

class WalletService
  extend CryptoHelper

  def self.create_wallet(user_id: 'null')
    url = "http://#{PAYMENT_API}/wallets/create"
    conn = Faraday.new(url: url)

    post_data = { user_id: user_id }

    res = conn.post('/api/v1/wallets/create', post_data).body

    parse_response(res)
  end


  def self.validate_address(address:, coin_type:)
    url = "http://#{PAYMENT_API}/#{coin_type.downcase}/validate/#{address}"

    conn = Faraday.new(url)

    parse_response(conn.get.body)
  end


  def self.fetch_address(address:, coin_type:)
    url = "http://#{PAYMENT_API}/#{coin_type.downcase}/find_by/#{address}"

    conn = Faraday.new(url)

    parse_response(conn.get.body)
  end

  def self.fetch_wallet(wallet_id:)
    url = "http://#{PAYMENT_API}/wallets/#{wallet_id}"

    conn = Faraday.new(url)

    parse_response(conn.get.body)
  end

  def self.create_address(wallet_id:, coin_type: 'BTC', deposit_amount:, expires_at:, trade_id:)
    unless coin_type == 'XMR'
      url = "http://#{PAYMENT_API}/btc/create"

      conn = Faraday.new(url)

      post_data = {
        wallet_id: wallet_id,
        coin_type: coin_type,
        expires_at: expires_at,
        trade_id: trade_id,
        deposit_amount: deposit_amount,
      }

      response = conn.post('/api/v1/btc/create', post_data).body

      parse_response(response)
    else
      url = "http://#{PAYMENT_API}/xmr/create_address"

      conn = Faraday.new(url)

      post_data = {
        wallet_id: wallet_id,
        expires_at: expires_at,
        trade_id: trade_id,
        deposit_amount: deposit_amount.to_s.delete('.').to_i
      }

      response = conn.post('/api/v1/xmr/create_address', post_data).body

      parse_response(response)
    end
  end


  def self.central_withdrawal(coin_amount:, target_address:, coin_type:)
    if coin_type == 'BTC'
      url = "http://#{PAYMENT_API}/transactions/withdraw"

      conn = Faraday.new(url)

      post_data = {
        coin_type: coin_type,
        coin_amount: coin_amount,
        target_address: target_address
      }

      response = conn.post('/api/v1/btc_transactions/withdraw', post_data).body

      parse_response(response).map(&:transaction_id)
    elsif coin_type == 'XMR'
      url       = "http://#{PAYMENT_API}/xmr/withdraw"
      conn = Faraday.new(url)

      post_data = {
        xmr_amount: coin_amount.to_s.delete('.').to_i,
        destination: target_address
      }

      response  = conn.post('/api/v1/xmr/withdraw', post_data).body

      res = parse_response(response)
      res ? [res] : res
    end
  end

  def self.central_balance(coin_type:)
    return false unless %w(BTC XMR).include? coin_type

    url   = "http://#{PAYMENT_API}/addresses/central_balance/#{coin_type}/"
    conn = Faraday.new(url)

    parse_response(conn.get.body)
  end


  def self.deduct_from(coin_amount:, coin_type:, wallet_id:)
    balance_method = :"#{coin_type.downcase}_balance"
    @wallet = fetch_wallet(wallet_id: wallet_id)

    balance = @wallet.send(balance_method).to_f
    if coin_type.downcase == 'xmr'
      balance = format_xmr(balance.to_f / 1000000000000 ).to_f
    end

    unless coin_type.downcase == 'xmr'
      new_balance = (balance.to_f - coin_amount.to_f ).round(8)
    else
      new_balance = ('%.12f' % (balance.to_f - ('%.12f' % coin_amount.to_f).to_f).round(12)).delete('.').to_i
    end

    if new_balance >= 0
      updated = update_wallet(
        wallet_id: wallet_id,
        new_balance: new_balance,
        coin_type: coin_type
      )

      OpenStruct.new({successful: updated.present?})
    else
      raise StandardError.new("Your #{balance_method} is too low to deduct #{coin_amount} from #{balance}.")
    end
  end

  def self.add_to(coin_amount:, coin_type:, wallet_id:)
    balance_method = :"#{coin_type.downcase}_balance"
    @wallet = fetch_wallet(wallet_id: wallet_id)

    balance = @wallet.send(balance_method).to_f
    if coin_type.downcase == 'xmr'
      balance = format_xmr(balance.to_f / 1000000000000 ).to_f
    end

    unless coin_type.downcase == 'xmr'
      new_balance = (balance + coin_amount.to_f).round(8)
    else
      new_balance = ('%.12f' % (balance.to_i + coin_amount.to_f).round(12)).delete('.').to_i
    end

    if new_balance > balance
      updated = update_wallet(
        wallet_id: wallet_id,
        new_balance: new_balance,
        coin_type: coin_type
      )
      OpenStruct.new({successful: updated.present?})
    else
      raise StandardError.new("Error adding balance to your wallet.")
    end
  end


  def self.update_wallet(wallet_id:, new_balance:, coin_type:)
    url = "http://#{PAYMENT_API}/wallets/#{wallet_id}"
    conn = Faraday.new(url)

    column = "#{coin_type.downcase}_balance"

    res = conn.put(url, { column => new_balance });
    parse_response(res.body)
  end


  def self.release_funds(coin_type:, coin_address:, destination:)
    url = "http://#{PAYMENT_API}/#{coin_type.downcase}/release_funds/#{coin_address}"
    conn = Faraday.new(url: url)

    post_data = { destination: destination }

    res = conn.post("/api/v1/#{coin_type.downcase}/release_funds/#{coin_address}", post_data).body

    parse_response(res)
  end


  private

  def self.parse_response(response)
    response = JSON.parse(response, object_class: OpenStruct)
    response.status == 'success' ? response.data : false
  end
end
