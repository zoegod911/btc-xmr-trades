class CreateTradeEscrows < ActiveRecord::Migration[6.0]
  def change
    create_table :trade_escrows, type: :uuid do |t|
      t.references :trade, type: :uuid, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.text :coin_address, null: false
      t.jsonb :destination, default: {}, null: false
      t.uuid :release_to_id, null: false, foreign_key: true
      t.boolean :released, default: false, null: false
      t.decimal :coin_amount, null: false

      t.timestamps
    end
    add_index :trade_escrows, :status
    add_index :trade_escrows, :destination
    add_index :trade_escrows, :release_to_id
    add_index :trade_escrows, :released
    add_index :trade_escrows, :coin_amount
  end
end
