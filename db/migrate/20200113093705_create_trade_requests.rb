class CreateTradeRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :trade_requests, id: :uuid do |t|
      t.string :from_crypto, null: false
      t.string :to_crypto, null: false
      t.decimal :coin_amount, null: false
      t.references :trader, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
    add_index :trade_requests, :from_crypto
    add_index :trade_requests, :to_crypto
    add_index :trade_requests, :coin_amount
  end
end
