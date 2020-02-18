class TradeChatMessage < ApplicationRecord
  jose_encrypt :content

  belongs_to :trade_chat
  belongs_to :sender, class_name: 'Trader', foreign_key: :sender_id

  has_one :attachment, class_name: 'TradeChatMessageAttachment', dependent: :destroy

  def decrypted
    PgpMessenger.decrypt_message(
      pgp_private_key: trade_chat.pgp_private_key,
      pgp_public_key: trade_chat.pgp_public_key,
      passphrase: trade_chat.passphrase,
      pgp_message: self.content
    )
  end
end
