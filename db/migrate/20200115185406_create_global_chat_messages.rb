class CreateGlobalChatMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :global_chat_messages, type: :uuid do |t|
      t.uuid :sender_id, foreign_key: true, null: false
      t.references :global_chat, type: :uuid, null: false, foreign_key: true
      t.text :content, null: false
      t.text :pinged_trader_ids, array: true, default: []


      t.timestamps
    end
    add_index :global_chat_messages, :pinged_trader_ids
    add_index :global_chat_messages, :sender_id
  end
end
