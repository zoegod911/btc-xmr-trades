class GlobalChat < ApplicationRecord
  has_many :global_chat_messages, dependent: :destroy

  def traders_in_chat
    Trader.joins(:user).where(id: self.trader_ids)
                       .merge(User.order(username: :desc))
  end

  def trader_ids
    self.present_trader_ids.map {|t| t['id'] }
  end
end
