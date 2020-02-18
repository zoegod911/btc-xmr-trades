require 'faraday'

class InvalidateGlobalChatTradersWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  def perform
    @chat = GlobalChat.first_or_create

    traders = @chat.present_trader_ids
    traders.each do |trader|
      if 30.minutes.ago >= DateTime.parse(trader['active_at'])
        traders.delete_at(traders.index(trader))
        @chat.present_trader_ids = traders
        @chat.save!
      end
    end

  end
end
