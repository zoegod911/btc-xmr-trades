class CreateTradeChatMessageAttachments < ActiveRecord::Migration[6.0]
  def change
    create_table :trade_chat_message_attachments, id: :uuid do |t|
      t.references :trade_chat_message, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
