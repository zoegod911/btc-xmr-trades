class TradeDispute < ApplicationRecord
  jose_encrypt :claim_reason, :claim_details

  belongs_to :trade

  belongs_to :plaintiff, class_name: 'Trader', foreign_key: :opened_by_id
  belongs_to :defendant, class_name: 'Trader', foreign_key: :against_id
  belongs_to :judge, class_name: 'User', foreign_key: :presiding_moderator_id, required: false

  def send_dispute_msg!
    dispute_bot_id = User.find_by(username: 'DisputeBot').id

    msg = "Buyer: '#{plaintiff.username}' has opened a dispute.\n\n Reason: "
    msg += "#{self.claim_reason}. \n\nMore details: \n\n"
    msg += "'#{self.claim_details}' \n\n "
    msg += "Moderators have been notified, and will chat here to determine the verdict."
    msg += "\n\nUntil then, please try to resolve this conflict amongst yourselves."
    msg += "We will be reviewing this chat."

    @chat = self.trade.trade_chat
    @new_message = TradeChatMessage.new({
      content: msg,
      sender_id: dispute_bot_id,
      trade_chat_id: @chat.id
    })

    pgp_message = PgpMessenger.encrypt_message(
      pgp_private_key: @chat.pgp_private_key,
      pgp_public_key: @chat.pgp_public_key,
      passphrase: @chat.passphrase,
      message: @new_message.content
    )

    @new_message.content = pgp_message
    @new_message.save!
  end

  def notify_defendant!
    msg =  "#{self.plaintiff.username} has opened a dispute for a trade."
    msg += " Reason: #{self.claim_reason}"

    Notification.create!(
      message: msg,
      user_id: self.defendant.user_id,
      destination_path: Rails.application.routes.url_helpers.trade_path(self.trade)
    )
  end

  def notify_moderators!
  end
end
