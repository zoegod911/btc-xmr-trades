class TradeChatsController < ApplicationController
  before_action :require_login, :require_2fa

  def add_message
    trade_chat_id = message_params[:trade_chat_id]
    @chat = TradeChat.find(trade_chat_id)

    not_empty = message_params[:content].present? || params[:attachment].present?
    if not_empty
      message_attrs = message_params.to_h.symbolize_keys

      if !message_attrs[:content].present? && params[:attachment].present?
        message_attrs[:content] = "#{params[:attachment].size} Files Attached:"
      end

      @new_message = TradeChatMessage.new(message_attrs)
      pgp_message = PgpMessenger.encrypt_message(
        pgp_private_key: @chat.pgp_private_key,
        pgp_public_key: @chat.pgp_public_key,
        passphrase: @chat.passphrase,
        message: @new_message.content
      )

      @new_message.content = pgp_message
      if @new_message.save!
        add_attachment(@new_message.id) if params[:attachment]

        redirect_to trade_path(@chat.trade.id), flash: {
          success: 'Message Sent.'
        }
      end
    else
      redirect_to trade_path(@chat.trade.id), flash: {
        error: 'Cannot send an empty message.'
      }
    end
  end

  private

  def add_attachment(message_id)
    params[:attachment].each do |file|
      @attachment = TradeChatMessageAttachment.new(
        trade_chat_message_id: message_id,
        attachments: file
      )
      @attachment.save!
    end
  end

  def message_params
    params.require(:trade_chat_message).permit(
      :content, :sender_id, :trade_chat_id
    )
  end
end
