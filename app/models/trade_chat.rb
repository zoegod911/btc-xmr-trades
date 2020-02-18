class TradeChat < ApplicationRecord
  jose_encrypt :pgp_public_key, :pgp_private_key, :passphrase

  belongs_to :trade
  has_many :trade_chat_messages
end
