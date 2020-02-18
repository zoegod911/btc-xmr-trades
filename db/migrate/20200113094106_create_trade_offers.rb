class CreateTradeOffers < ActiveRecord::Migration[6.0]
  def change
    create_table :trade_offers, id: :uuid do |t|
      t.references :trade_request, type: :uuid, null: false, foreign_key: true
      t.uuid :sender_id, null: false, foreign_key: true
      t.decimal :coin_amount, null: false
      t.boolean :accepted, default: false, null: false

      t.timestamps
    end
    add_index :trade_offers, :sender_id
    add_index :trade_offers, :coin_amount
    add_index :trade_offers, :accepted
  end
end
