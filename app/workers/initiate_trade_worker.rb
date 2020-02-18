require 'faraday'

class InitiateTradeWorker
  include Sidekiq::Worker
  include CryptoHelper
  include Rails.application.routes.url_helpers

  def perform(trade_id, offering_id, coin_amount)
    @trade = Trade.find(trade_id)
    @offering = Offering.find(offering_id)

    deposit_amount = coin_amount
    if @offering.coin_type == 'XMR'
      deposit_amount = format_xmr(deposit_amount).to_s.delete('.').to_i
    end

    @deposit_address = WalletService.create_address(
      wallet_id: @offering.seller.wallet_id,
      coin_type: @offering.coin_type,
      expires_at: @trade.expires_at,
      deposit_amount: deposit_amount,
      trade_id: @trade.id
    )

    @escrow = TradeEscrow.new(
      trade_id: @trade.id,
      coin_amount: coin_amount,
      coin_address: @deposit_address.address,
      release_to_id: @offering.seller.id
    )

    if @escrow.save!
      @trade.create_qr_code

      pass = SecureRandom.base64(69)
      chat_generated = PgpService.generate_trade_chat(
        trade_id: @trade.id,
        passphrase: pass
      )

      if chat_generated
        [@trade.seller.user_id, @trade.buyer.user_id].each do |u_id|
          Notification.create(
            user_id: u_id,
            destination_path: trade_path(@trade),
            message: "New Trade: #{@escrow.coin_amount.to_f} #{@offering.coin_type} for #{@trade.target_amount} #{@offering.target_currency} #{@offering.trade_item.title}.",
          )
        end
      end
    end
  end
end
