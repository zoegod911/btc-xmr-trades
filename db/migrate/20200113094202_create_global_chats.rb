class CreateGlobalChats < ActiveRecord::Migration[6.0]
  def change
    create_table :global_chats, id: :uuid do |t|
      t.jsonb :present_trader_ids, default: [], null: false

      t.timestamps
    end
    add_index :global_chats, :present_trader_ids
  end
end
