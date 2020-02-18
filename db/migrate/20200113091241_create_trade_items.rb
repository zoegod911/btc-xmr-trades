class CreateTradeItems < ActiveRecord::Migration[6.0]
  def change
    create_table :trade_items, id: :uuid do |t|
      t.references :category, type: :uuid, null: false, foreign_key: true
      t.string :title
      t.string :slug

      t.timestamps
    end
    add_index :trade_items, :title
    add_index :trade_items, :slug
  end
end
