class TradesController < ApplicationController
  before_action :require_login, :require_2fa

  def create
    @offering = Offering.find(trade_params[:offering_id])

    min_trades = @offering.minimum_trades_completed
    if @current_user.trader.total_completed_trades < min_trades
      search_start_path = exchange_path(
        t_id: @offering.trade_item_id,
        currency: @offering.target_currency,
        target_amount: trade_params[:target_amount]
      )

      redirect_to search_start_path, flash: {
        notice: "This trade requires a minimum of #{min_trades} completed trades..."
      }
      return
    end

    coin_amount  = trade_params[:coin_amount].to_f

    locked_coin_price = CryptoConversion.convert(
      coin_amount: 1,
      from_currency: @offering.coin_type,
      to_currency: @offering.target_currency,
    )

    @trade = Trade.new(
      status: :in_progress,
      offering_id: @offering.id,
      expires_at: 1.hour.from_now,
      buyer_id: trade_params[:buyer_id],
      locked_coin_price: locked_coin_price,
      target_amount: trade_params[:target_amount]
    )

    if @trade.save!
      InitiateTradeWorker.perform_async(@trade.id, @offering.id, coin_amount)

      redirect_to root_path, flash: {
        notice: 'We are generating your trade... Keep a look out for a notification.'
      }
    end
  end

  def show
    @trade = Trade.find(params[:id])
    if DateTime.now >= @trade.expires_at && @trade.status == 'in_progress'
      @trade.expired!
    end

    @trade_chat = @trade.trade_chat
    @address = WalletService.fetch_address(
      coin_type: @trade.coin_type,
      address: @trade.trade_escrow.coin_address
    )
  end

  def index
    @trader = current_user.trader

    if params[:buying].present?
      @active_trades    = @trader.buyer_trades.filter(&:active?)
      @completed_trades = @trader.buyer_trades.filter(&:completed?)
      @disputed_trades  = @trader.buyer_trades.filter(&:disputed?)
    elsif params[:selling].present?
      @active_trades    = @trader.seller_trades.filter(&:active?)
      @completed_trades = @trader.seller_trades.filter(&:completed?)
      @disputed_trades  = @trader.seller_trades.filter(&:disputed?)
    end
  end

  def user_paid
    @trade = Trade.find(params[:id])

    if current_user.trader.id == @trade.buyer_id
      if @trade.update(status: :user_paid)
        Notification.create!(
          user_id: @trade.seller.user_id,
          destination_path: trade_path(@trade),
          message: "#{@trade.buyer.username} has sent a payment for a trade."
        )

        redirect_to trade_path(@trade), flash: {
          success: 'Notified seller of payment.'
        }
      end
    end
  end

  def mark_complete
    @trade = Trade.find(params[:id])
    @address = WalletService.fetch_address(
      coin_type: @trade.coin_type,
      address: @trade.trade_escrow.coin_address
    )

    coins_deposited = !@address.active

    if coins_deposited && current_user.trader.id == @trade.seller.id
      if @trade.update(status: :completed)
        @trade.trade_escrow.update(release_to_id: @trade.buyer.id)
        payment = @trade.trade_escrow.release_coins

        if payment
          Notification.create!(
            user_id: @trade.buyer.user_id,
            destination_path: trade_path(@trade),
            message: "'#{@trade.seller.username}' has released the coins."
          )

          redirect_to trade_path(@trade), flash: {
            success: 'Trade Completed. Coins have been released.'
          }
        else
          if @trade.trade_escrow.send_to.nil?
            Notification.create!(
              user_id: @trade.buyer.user_id,
              destination_path: trade_path(@trade),
              message: "You must set the destination address for your #{@trade.coin_amount} #{@trade.coin_type}."
            )

            redirect_to trade_path(@trade), flash: {
              success: 'Trade Completed. The buyer must set the destination for the coins.'
            }
          end
        end
      else
        Notification.create!(
          user_id: @trade.seller.user_id,
          destination_path: trade_path(@trade),
          message: "You must deposit #{@trade.coin_amount} #{@trade.coin_type} into the trade."
        )
      end
    end
  end

  def request_expiry_extension
    @trade = Trade.find(params[:id])

    if current_user.id == @trade.buyer.user_id
      if @trade.update(requested_extension: true)
        Notification.create!(
          user_id: @trade.seller.user_id,
          destination_path: trade_path(@trade),
          message: "#{@trade.buyer.username} has requested an extension on a trade."
        )

        redirect_to trade_path(@trade), flash: {
          success: 'Requested an extension from the seller.'
        }
      end
    end
  end

  def extend_expiry
    @trade = Trade.find(params[:id])

    if current_user.id == @trade.seller.user_id
      if @trade.update(expires_at: DateTime.now + 1.hour)
        Notification.create!(
          user_id: @trade.buyer.user_id,
          destination_path: trade_path(@trade),
          message: "'#{@trade.seller.username}' has extended the trade expiry time."
        )

        redirect_to trade_path(@trade), flash: {
          success: "You've extended the trade expiration time."
        }
      end
    end
  end

  def set_destination_address
    @trade = Trade.find(params[:id])
    is_buyer  = current_user.id == @trade.buyer.user_id
    is_seller = current_user.id == @trade.seller.user_id

    @address = WalletService.fetch_address(
      coin_type: @trade.coin_type,
      address: @trade.trade_escrow.coin_address
    )

    if is_buyer || is_seller
      if @trade.trade_escrow.update(trade_escrow_params)

        address_type = is_seller ? 'seller' : 'buyer'
        address = @trade.trade_escrow.destination[address_type]

        if (@trade.completed? || @trade.expired?) && !@address.released
          @trade.trade_escrow.release_coins
        end

        redirect_to trade_path(@trade), flash: {
          success: "You've set your destination #{@trade.offering.coin_type} Address: #{address}."
        }
      else
        redirect_to trade_path(@trade), flash: {
          error: @trade.trade_escrow.errors.messages.map {|k, v| "#{k} #{v[0]}" }
        }
      end
    end
  end


  private

  def trade_params
    params.require(:trade).permit(
      :offering_id, :buyer_id, :coin_amount, :target_amount
    )
  end

  def trade_escrow_params
    params.require(:trade_escrow).permit(destination: [:buyer, :seller])
  end
end
