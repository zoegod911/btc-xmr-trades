PAYMENT_API   = if Rails.env.development? || Rails.env.test?
  'localhost:8000/api/v1'
else
  Rails.application.credentials.payment_api
end

COUNTRIES = ISO3166::Country.all_translated.reject do |country|
  country == 'China'
end.prepend(%w(Worldwide Europe)).flatten.freeze

CURRENCIES = %i(USD CAD HKD ISK PHP DKK HUF CZK GBP RON SEK IDR INR BRL RUB HRK
  JPY THB CHF EUR MYR BGN TRY CNY NOK NZD ZAR MXN SGD AUD ILS KRW PLN
).freeze

COIN_TYPES    = %i(BTC XMR)
PRODUCT_TYPES = %i(digital physical).freeze
GRADES        = %w(A+++ A+ A B+ B B- C C- D F F-).freeze
CLAIM_REASONS = [
  'I want a refund.',
  'Vendor is a scammer.',
  'Never received a shipment.',
  'Package was not as advertised.',
  'My order was seized by law enforcement.'
].freeze

CAPTCHA_WORKER = 'http://pangolnnvqwl6aqrg65guqziv5vlnvz3wnxz6ty74kep7tzpexk7wiid.onion'

require "#{Rails.root}/app/workers/crypto_ticker_worker"
CryptoTickerWorker.new.perform
