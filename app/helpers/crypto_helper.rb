module CryptoHelper
  include MoneyRails::ActionViewExtension

  def to_bitcoin(fiat_amount, user: current_user)
    CryptoConversion.convert(
      to_currency: 'BTC',
      coin_amount: fiat_amount,
      from_currency: user.default_currency
    )
  end

  def to_monero(fiat_amount, user: current_user)
    CryptoConversion.convert(
      to_currency: 'XMR',
      coin_amount: fiat_amount,
      from_currency: user.default_currency
    )
  end

  def btc_to_usd(btc_amount)
    CryptoConversion.convert(
      from_currency: 'BTC', to_currency: 'USD', coin_amount: btc_amount
    )
  end

  def xmr_to_usd(xmr_amount)
    xmr_amount = format_xmr(xmr_amount)

    CryptoConversion.convert(
      from_currency: 'XMR', to_currency: 'USD', coin_amount: xmr_amount
    )
  end

  def to_default_currency(usd_amount, raw: false, user: nil)
    user ||= current_user
    raise StandardError.new('User not logged in.') unless user

    if user.default_currency == 'USD'
      return Money.new(usd_amount * 100, 'USD')
    end

    converted = Money.new(usd_amount).exchange_to(current_user.default_currency)
    raw ? converted : humanized_money_with_symbol(converted.round(2))
  end

  def btc_to_default_currency(btc_amount, raw: false, user: nil)
    user ||= current_user

    # convert to USD
    usd = btc_to_usd(btc_amount)

    # usd to other fiat currency
    to_default_currency(usd, raw: raw, user: user)
  end

  def xmr_to_default_currency(xmr_amount, raw: false, user: nil)
    user ||= current_user

    # convert to USD
    usd = xmr_to_usd(xmr_amount)

    # usd to other fiat currency
    to_default_currency(usd, raw: raw, user: user)
  end

  def format_xmr(xmr_amount)
    xmr = '%.12f' % xmr_amount
  end
end
