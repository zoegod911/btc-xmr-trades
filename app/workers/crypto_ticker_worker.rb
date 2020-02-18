require 'faraday'
require 'bigdecimal'
require 'money-rails/helpers/action_view_extension'
require "#{Rails.root}/app/services/crypto_conversion"

Money.infinite_precision = true

class CryptoTickerWorker
  include Sidekiq::Worker
  include MoneyRails::ActionViewExtension

  def perform
    btc = CryptoConversion.convert(
      from_currency: 'BTC', to_currency: 'USD', coin_amount: 1
    )
    xmr = CryptoConversion.convert(
      from_currency: 'XMR', to_currency: 'USD', coin_amount: 1
    )

    btc_pricing = [{
        price: humanized_money_with_symbol(btc),
        currency: 'USD'
    }]
    xmr_pricing = [{
        price: humanized_money_with_symbol(xmr),
        currency: 'USD'
    }]


    currencies = %w(
      EUR GBP AUD CAD CNY HUF JPY	HKD	RON	SEK	IDR INR BRL RUB	HRK CZK THB	CHF
      PHP	MYR	BGN TRY	DKK	NOK	NZD	ZAR	MXN	SGD	ISK	ILS	KRW	PLN
    ).each do |currency|
      bitcoin_price = CryptoConversion.convert(
        coin_amount: 1,
        from_currency: 'BTC',
        to_currency: currency
      ).to_f

      monero_price = CryptoConversion.convert(
        coin_amount: 1,
        from_currency: 'XMR',
        to_currency: currency
      ).to_f

      btc_pricing << {
        price: humanized_money_with_symbol(bitcoin_price),
        currency: currency
      }
      xmr_pricing << {
        price: humanized_money_with_symbol(monero_price),
        currency: currency
      }
    end

    # invalidate cache if set
    btc_preset = Rails.cache.fetch('BITCOIN').present?
    xmr_preset = Rails.cache.fetch('MONERO').present?
    preset = btc_preset && xmr_preset
    if preset
      %w(BITCOIN MONERO).each do |cache_key|
        Rails.cache.delete(cache_key)
      end
    end

    Rails.cache.write('BITCOIN', btc_pricing)
    Rails.cache.write('MONERO', xmr_pricing)
  end

end
