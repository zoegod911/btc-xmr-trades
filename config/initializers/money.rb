require 'faraday'

Money.locale_backend = :i18n

Money.default_currency = 'USD'

xmr = {
  "priority": 100,
  "iso_code": 'XMR',
  "name": "Monero",
  "symbol": 'XMR',
  "alternate_symbols": [],
  "subunit": 'Satoshi',
  "subunit_to_unit": 1000000000000,
  "symbol_first": true,
  "html_entity": '',
  "decimal_mark": '.',
  "thousands_separator": ',',
  "iso_numeric": '',
  "smallest_denomination": 1
}

Money::Currency.register(xmr)

MoneyRails.configure do |config|
  config.default_currency = :usd

  config.no_cents_if_whole = false

  config.default_format = {
    symbol: true,
    no_cents_if_whole: false,
    sign_before_symbol: true
  }
end
