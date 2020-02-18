class CreateTrades < ActiveRecord::Migration[6.0]
  def change
    create_table :trades, id: :uuid do |t|
      t.uuid :offering_id, null: false, foreign_key: true
      t.uuid :buyer_id, foreign_key: true, null: false
      t.integer :status, null: false
      t.datetime :expires_at, null: false
      t.decimal :locked_coin_price, null: false
      t.decimal :target_amount, null: false
      t.boolean :requested_extension, default: false, null: false
      t.boolean :seller_reviewed, default: false, null: false
      t.boolean :buyer_reviewed, default: false, null: false
      t.text :qr_code_data

      t.timestamps
    end
    add_index :trades, :buyer_id
    add_index :trades, :status
    add_index :trades, :expires_at
    add_index :trades, :locked_coin_price
  end
end
