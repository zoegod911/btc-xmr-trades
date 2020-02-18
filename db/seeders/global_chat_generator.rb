class GlobalTradeChatGenerator
  def self.generate!
    @chat = GlobalTradeChat.create!
  end
end
