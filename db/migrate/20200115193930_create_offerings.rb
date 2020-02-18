class CreateOfferings < ActiveRecord::Migration[6.0]
  def change
    create_table :offerings, id: :uuid do |t|
      t.uuid :seller_id, foreign_key: true, null: false
      t.integer :coin_type, null: false
      t.decimal :price_per_coin, null: false
      t.decimal :minimum_price, null: false
      t.decimal :maximum_price, null: false
      t.string :target_currency, null: false
      t.references :trade_item, type: :uuid, null: false, foreign_key: true
      t.integer :minimum_trades_completed, null: false
      t.text :description, null: false
      t.boolean :grey_market, default: false, null: false

      t.timestamps
    end
    add_index :offerings, :coin_type
    add_index :offerings, :price_per_coin
    add_index :offerings, :target_currency
    add_index :offerings, :minimum_price
    add_index :offerings, :maximum_price
    add_index :offerings, :grey_market
    add_index :offerings, :minimum_trades_completed
  end
end
