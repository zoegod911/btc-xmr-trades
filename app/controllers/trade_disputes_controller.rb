class TradeDisputesController < ApplicationController
  before_action :require_login, :require_captcha, :require_2fa, :require_trader

  def new
    @trade = Trade.find(params[:t_id])

    if @trade.buyer_id == current_user.trader.id
      @started_by_user = @trade.buyer_id
      @against_user = @trade.seller.id
    else
      redirect_to root_path, flash: {
        error: 'Only the buyer can dispute a trade.'
      }
    end
  end

  def create
    trade_disputes_attrs = trade_disputes_params.except(:other_reason)
    if params[:other_reasons]
      trade_disputes_attrs[:claim_reason] = trade_disputes_params[:claim_reason]
    end

    @dispute = TradeDispute.new(trade_disputes_attrs)

    if @dispute.save! && @dispute.trade.update(status: :disputed)
      @dispute.notify_defendant!
      @dispute.send_dispute_msg!

      redirect_to trade_path(@dispute.trade), flash: {
        notice: 'You have started a dispute. Moderators have been notified.'
      }
    end
  end

  def show
  end

  private

  def trade_disputes_params
    params.require(:trade_dispute).permit(
      :claim_reason, :other_reason, :claim_details, :trade_id, :opened_by_id,
      :against_id
    )
  end
end
