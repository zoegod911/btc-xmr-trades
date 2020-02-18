class ExpireTradeWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  def perform
    Trade.where(status: :in_progress).each do |trade|
      if DateTime.now >= trade.expires_at
        trade.expired!

        coins = WalletService.fetch_address(
          coin_type: trade.coin_type,
          address: trade.trade_escrow.coin_address
        )

        unless coins.released && coins.active == false
          trade.trade_escrow.release_coins
        end

        [trade.buyer.user_id, trade.seller.user_id].each do |id|
          Notification.create!(
            user_id: id,
            destination_path: trade_path(trade),
            message: "Trade Expired: #{trade.coin_amount.to_f} #{trade.coin_type} for #{trade.target_amount} #{trade.offering.target_currency} #{trade.offering.trade_item.title}."
          )
        end
      end
    end
  end
end
