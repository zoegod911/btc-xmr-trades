class ReviewsController < ApplicationController
  def create
    @trade = Trade.find(review_params[:trade_id])
    if @trade
      @review = Review.new(review_params)
      @review.trusted = false if @review.trusted.nil?

      is_buyer  = current_user.trader.id == @trade.buyer.id
      is_seller = current_user.trader.id == @trade.seller.id
      reviewee_is_buyer = @review.reviewee_id  == @trade.buyer_id
      reviewee_is_seller = @review.reviewee_id == @trade.seller.id


      active_tab = :buyer   if reviewee_is_buyer
      active_tab = :seller  if reviewee_is_seller

      role = 'buyer'  if is_buyer
      role = 'seller' if is_seller

      unless [is_buyer, is_seller].any?
        redirect_to root_path, flash: {
          error: 'Attempted an unauthorized action. Moderators will be notified.'
        }
        return
      end

      if @review.save! && @trade.update("#{role}_reviewed" => true)
        @review.calculate_trust_score!

        redirect_to trader_path(id: @review.reviewee_id, active_tab => true), flash: {
          success: 'Left a review.'
        }
      end
    end
  end

  private

  def review_params
    params.require(:review).permit(
      :reviewee_id, :reviewer_id, :trade_id, :trusted, :content
    )
  end
end
