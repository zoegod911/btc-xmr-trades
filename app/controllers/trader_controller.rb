class TraderController < ApplicationController
  before_action :require_login, :require_2fa
  
  def show
    @trader = Trader.friendly.find(params[:id])
  end
end
