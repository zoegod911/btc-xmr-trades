class CreateTradeChats < ActiveRecord::Migration[6.0]
  def change
    create_table :trade_chats, id: :uuid do |t|
      t.text :pgp_public_key, null: false
      t.text :pgp_private_key, null: false
      t.text :passphrase, null: false
      t.references :trade, type: :uuid,  null: false, foreign_key: true

      t.timestamps
    end
  end
end
