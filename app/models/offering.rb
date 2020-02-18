class Offering < ApplicationRecord
  include CryptoHelper

  jose_encrypt :description

  belongs_to :trade_item
  belongs_to :seller, class_name: 'Trader', foreign_key: :seller_id

  has_many :trades, dependent: :destroy

  enum coin_type: %i(BTC XMR)

  def active_trades
    self.trades.select(&:active?)
  end

  def completed_trades
    self.trades.reject(&:active?)
  end

  def payout_amount(fiat_amount:, fiat_currency: self.target_currency)
    fiat = payout_fiat(
      fiat_amount: fiat_amount.to_f,
      fiat_currency: fiat_currency
    )

    coin_payout = CryptoConversion.convert(
      from_currency: fiat_currency,
      to_currency: self.coin_type,
      coin_amount: fiat.to_f
    )

    coin_payout = format_xmr(coin_payout) if coin_type == 'XMR'

    {
      fiat: Money.new(fiat.to_f * 100, self.target_currency),
      coin: coin_payout
    }
  end

  def payout_fiat(fiat_currency: self.target_currency, fiat_amount:)
    current_price = current_coin_price(currency: fiat_currency)

    payout_fiat = fiat_amount.to_f * exchange_rate(current_price: current_price).to_f
    Money.new(payout_fiat * 100, fiat_currency) {|m| m.round(2)}
  end

  def exchange_rate(current_price:)
    exchange_rate = (current_price / self.price_per_coin.to_f).round(2)
    Money.new(exchange_rate * 100, self.target_currency)
  end

  def current_coin_price(currency: )
    cache_key = coin_type_to_cache_key[self.coin_type]

    price_data = Rails.cache.fetch(cache_key)
    price_for_currency = price_data.select{|p| p[:currency] == currency}[0]

    price_for_currency[:price].remove('$').remove(',').to_f
  end

  private

  def coin_type_to_cache_key
    { 'XMR' => 'MONERO', 'BTC' => 'BITCOIN' }
  end
end
