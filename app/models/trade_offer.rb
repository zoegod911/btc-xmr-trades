class TradeOffer < ApplicationRecord
  belongs_to :trader, class_name: 'Trader', foreign_key: :sender_id

  belongs_to :trade_request
  has_one :requester, class_name: 'Trader', through: :instant_trade_request, source: :trader

  # Calculation methods

  def platform_fee(user:)
    calculate_platform_fee(
      user: user,
      coin_amount: self.coin_amount,
      coin_type: instant_trade_request.to_crypto.downcase
    )
  end

  def miners_fee(user:)
    calculate_miners_fee(
      user: user,
      coin_type: instant_trade_request.to_crypto.downcase
    )
  end

  def fees(user:)
    plaform_fee(user: user) + miners_fee(user: user)
  end

  def coins_received(user: user)
    total_fees = fees(user: user)

    unless instant_trade_request.to_crypto == 'XMR'
      (self.coin_amount - total_fees).round(8)
    else
      after_fees = ('%.12f' % (self.coin_amount - total_fees)).to_f
      format_xmr(after_fees)
    end
  end
end
