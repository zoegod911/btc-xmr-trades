class OfferingsController < ApplicationController
  before_action :require_login, :require_2fa

  def new
    @offering = Offering.new
    @coin_pricing = calc_coin_prices
  end


  def edit
    @offering = Offering.find(params[:id])
    @trade_item = @offering.trade_item
    @coin_pricing = calc_coin_prices
  end


  def show
    @offering = Offering.find(params[:id])
    @trade_item = @offering.trade_item
    @target_amount = params[:target_amount]
  end


  def index
    page = params[:page] || 1
    @categories = Category.all
    @trade_amount = params[:target_amount].try(:to_f)
    @trade_item = params[:t_id].nil? ? nil : TradeItem.find(params[:t_id])

    where = construct_where(
      currency: params[:currency],
      coin_type: params[:coin_type],
      grey_market: params[:grey_market],
      trade_item_id: @trade_item.try(:id)
    )

    @offerings = Offering.includes(:trade_item, seller: :user).where(where)
    if @target_amount.present?
      min_query = Offering.arel_table[:minimum_price].lteq(opts[:trade_amount])
      max_query = Offering.arel_table[:maximum_price].gteq(opts[:trade_amount])
      @offerings = @offerings.where(min_query).where(max_query)
    end

    @offerings = @offerings.paginate(page: page, per_page: 30)
  end


  def create
    @offering = Offering.new(offering_params)

    if @offering.save!
      redirect_to offering_path(@offering), flash: {
        success: 'Posted a new trade.'
      }
    end
  end

  def update
    @offering = Offering.find(params[:id])

    if @offering.update!(offering_params)
      redirect_to offering_path(@offering), flash: {
        success: 'Your trade has been successfully updated.'
      }
    end
  end

  def destroy
    @offering = Offering.find(params[:id])

    if @offering.destroy
      redirect_to trades_path(selling: true), flash: {
        error: 'Your trade has been deleted.'
      }
    end
  end


  private

  def offering_params
    params.require(:offering).permit(
      :coin_type, :trade_item_id, :target_currency, :price_per_coin,
      :description, :minimum_price, :maximum_price, :locked_to_countries,
      :seller_id, :minimum_trades_completed, :grey_market
    )
  end

  def construct_where(opts)
    where = {}

    where.merge!(trade_item_id: opts[:trade_item_id]) if opts[:trade_item_id]
    where.merge!(coin_type: opts[:coin_type]) if opts[:coin_type]
    where.merge!(target_currency: opts[:currency]) if opts[:currency]
    where.merge!(grey_market: true) if opts[:grey_market]

    where
  end

  def calc_coin_prices
    coin_prices = {}

    %w(BTC XMR).each do |curr|
      cache_key = coin_type_to_cache_key[curr]

      price_data = Rails.cache.fetch(cache_key)
      currency = current_user.default_currency
      price_for_currency = price_data.select{|p| p[:currency] == currency }[0]

      coin_price = price_for_currency[:price].remove('$').remove(',').to_f
      coin_prices[curr.downcase.to_sym] = coin_price
    end

    coin_prices
  end

  def coin_type_to_cache_key
    { 'XMR' => 'MONERO', 'BTC' => 'BITCOIN' }
  end
end
