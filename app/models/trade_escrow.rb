class TradeEscrow < ApplicationRecord
  include Rails.application.routes.url_helpers

  validates_with DestinationAddressValidator
  
  belongs_to :trade

  belongs_to :payee, class_name: 'Trader', foreign_key: :release_to_id
  has_one :offering, through: :trade

  def send_to
    release_to = self.release_to_id == self.offering.seller.id ? 'seller' : 'buyer'
    send_to = self.destination[release_to]
  end

  def release_coins
    if send_to
      transaction = WalletService.release_funds(
        coin_type: self.offering.coin_type,
        coin_address: self.coin_address,
        destination: send_to
      )

      true
    else
      Notification.create(
        user_id: self.payee.user_id,
        destination_path: trade_path(self.trade),
        message: "You must set your destination #{self.trade.coin_type} Address to receive your #{self.coin_amount} #{self.trade.coin_type}."
      )

      false
    end
  end
end
