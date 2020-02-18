class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications, id: :uuid do |t|
      t.text :message, null: false
      t.text :destination_path, null: false
      t.boolean :seen, default: false, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :notifications, :seen
    add_index :notifications, :message
  end
end
