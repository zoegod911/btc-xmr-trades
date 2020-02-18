class CreateTradeDisputes < ActiveRecord::Migration[6.0]
  def change
    create_table :trade_disputes, id: :uuid do |t|
      t.uuid :opened_by_id,  foreign_key: true, null: false
      t.uuid :against_id, foreign_key: true, null: false
      t.integer :presiding_moderator_id, foreign_key: true
      t.text :claim_details, null: false
      t.text :claim_reason, null: false
      t.references :trade, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
    add_index :trade_disputes, :opened_by_id
    add_index :trade_disputes, :against_id
    add_index :trade_disputes, :presiding_moderator_id
  end
end
