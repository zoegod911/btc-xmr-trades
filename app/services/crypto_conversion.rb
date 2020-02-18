require 'faraday'

class CryptoConversion
  def self.convert(coin_amount:, from_currency: 'USD', to_currency:)
    return 0 if coin_amount.to_f <= 0


    url = 'https://apiv2.bitcoinaverage.com/convert/global'
    url += "?from=#{from_currency}&to=#{to_currency}&amount=#{coin_amount}"

    conn = Faraday.new(url: url) do |f|
      f.headers['X-ba-key'] = Rails.application.credentials.bitcoinaverage
      f.adapter :httpclient
    end

    res = JSON.parse(conn.get.body, object_class: OpenStruct)

    res.success ?  res.price : error_msg
  end

  private

  def self.error_msg
    error_msg = 'Unable to fetch price conversion fron BitcoinAverage'
    raise StandardError.new(error_msg)
  end
end
