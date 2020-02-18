class InstantTradeOffersController < ApplicationController
  before_action :require_login, :require_captcha, :require_trader

  def new
    @request = InstantTradeRequest.find(params[:instant_trade_request_id])

    if @request.present?
      instant_trade_offer_attrs = {
        trader_id: current_user.trader.id,
        instant_trade_request_id: @request.id,
        coin_amount: instant_trade_offer_params[:coin_amount]
      }
      @offer = InstantTradeOffer.new(instant_trade_offer_attrs)

      request_method = :"#{@request.from_crypto.downcase}_to_default_currency"
      user_receives = @request.coins_received(user: current_user)
      @request_pricing = {
        coins_received: user_receives,
        fees: @request.fees(user: current_user),
        nibiru_fee: @request.nibiru_fee(user: current_user),
        miners_fee: @request.miners_fee(user: current_user),
        as_fiat: helpers.send(request_method, user_receives)
      }

      offer_method = :"#{@request.to_crypto.downcase}_to_default_currency"
      trader_receives = @offer.coins_received(user: current_user)
      @offer_pricing = {
        coins_received: trader_receives,
        fees: @offer.fees(user: current_user),
        nibiru_fee: @offer.nibiru_fee(user: current_user),
        miners_fee: @offer.miners_fee(user: current_user),
        as_fiat: helpers.send(offer_method, trader_receives)
      }
    else
      chat = GlobalTradeChat.first
      redirect_to global_trade_chat_new_trade_request_path(chat), flash: {
        notice: 'Unable to find Trade Request...'
      }
    end
  end

  def create
    req_id = instant_trade_offer_params[:instant_trade_request_id]

    @request = InstantTradeRequest.find(req_id)
    @offer = InstantTradeOffer.new(instant_trade_offer_params)
    @offer.trader_id = current_user.trader.id

    @coin_type = @request.to_crypto
    balance_method = :"#{@coin_type.downcase}_balance"
    @wallet = WalletService.fetch_wallet(wallet_id: current_user.wallet_id)

    coin_balance  = @wallet.send(:"#{@coin_type.downcase}_balance").to_f
    coin_balance  = helpers.format_xmr(coin_balance).to_f if @coin_type == 'XMR'

    chat = GlobalTradeChat.first
    enough_balance  = coin_balance >= @offer.coin_amount
    if enough_balance
      if @offer.save
        redirect_to global_trade_chat_index_path(chat), flash: {
          notice: "Offer submitted to #{@offer.instant_trade_request.trader.username}."
        }
      end
    else
      redirect_to global_trade_chat_index_path(chat), flash: {
        error: "Not enough #{@coin_type} in your wallet."
      }
    end
  end

  def show
    @offer = InstantTradeOffer.find(params[:id])
    @request = @offer.instant_trade_request

    request_method = :"#{@request.from_crypto.downcase}_to_default_currency"
    user_receives = @request.coins_received(user: current_user)
    @request_pricing = {
      coins_received: user_receives,
      fees: @request.fees(user: current_user),
      nibiru_fee: @request.nibiru_fee(user: current_user),
      miners_fee: @request.miners_fee(user: current_user),
      as_fiat: helpers.send(request_method, user_receives)
    }

    offer_method = :"#{@request.to_crypto.downcase}_to_default_currency"
    trader_receives = @offer.coins_received(user: current_user)
    @offer_pricing = {
      coins_received: trader_receives,
      fees: @offer.fees(user: current_user),
      nibiru_fee: @offer.nibiru_fee(user: current_user),
      miners_fee: @offer.miners_fee(user: current_user),
      as_fiat: helpers.send(offer_method, trader_receives)
    }
  end

  def withdraw_offer
  end

  def confirm_trade
    @offer = InstantTradeOffer.find(params[:instant_trade_offer_id])
    @request = @offer.instant_trade_request

    if @offer.present?
      accepted = instant_trade_offer_params[:accepted]

      if accepted
        begin
          if @offer.perform_trade.successful
            @offer.instant_trade_request.destroy

            redirect_to wallet_path(current_user.wallet_id), flash: {
              success: 'Instant Trade has been completed.'
            }
          end
        rescue StandardError => e
          puts e.backtrace
          redirect_to wallet_path(current_user.wallet_id), flash: {
            notice: e.message
          }
        end
      else
        chat = GlobalTradeChat.first
        if @offer.request.destroy
          redirect_to global_trade_chat_index_path(chat), flash: {
            notice: 'You have declined the trade offer.'
          }
        end
      end
    end
  end


  private

  def after_fees(coin_type:, coin_amount:, fees:)

  end

  def instant_trade_offer_params
    params.require(:instant_trade_offer).permit(
      :coin_amount, :instant_trade_request_id, :accepted
    )
  end
end
