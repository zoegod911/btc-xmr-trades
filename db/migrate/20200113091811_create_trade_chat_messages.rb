class CreateTradeChatMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :trade_chat_messages, id: :uuid do |t|
      t.uuid :sender_id, null: false, foreign_key: true
      t.references :trade_chat, type: :uuid, null: false, foreign_key: true
      t.text :content, null: false
      t.boolean :edited, default: false, null: false

      t.timestamps
    end
    add_index :trade_chat_messages, :sender_id
    add_index :trade_chat_messages, :edited
  end
end
