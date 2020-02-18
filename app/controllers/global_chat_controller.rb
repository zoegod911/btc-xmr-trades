class GlobalChatController < ApplicationController
  before_action :require_login, :require_2fa

  def index
    @chat = if GlobalChat.count > 0
        GlobalChat.first
      else
        GlobalChat.create(present_trader_ids: [])
      end

    t_id = current_user.trader.id

    unless @chat.trader_ids.map.include? t_id
      @chat.present_trader_ids << { id: t_id, active_at: DateTime.now }
    else
      @chat.present_trader_ids.delete_if {|f| f['id'] == t_id }
      @chat.present_trader_ids << { id: t_id, active_at: DateTime.now }
    end

    @chat.save!

    @present_traders = @chat.traders_in_chat
    @requests = TradeRequest.all
    @offers = current_user.trader.trade_offers
  end

  def send_message
    @chat = GlobalChat.first
    @message = GlobalChatMessage.new(
      global_chat_id: @chat.id,
      sender_id: current_user.trader.id,
      content: global_chat_message_params[:content]
    )

    if @message.save!
      redirect_to global_chat_index_path, flash: {
        notice: 'Message sent.'
      }
    end
  end

  private

  def global_chat_message_params
    params.require(:global_chat_message).permit(:content)
  end
end
