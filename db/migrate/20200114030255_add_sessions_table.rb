class AddSessionsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :sessions, id: :uuid do |t|
      t.string :session_id, null: false
      t.text :data
      t.datetime :last_request_at, default: DateTime.now, null: false
      t.integer  :offensive_requests, default: 0, null: false
      t.boolean  :blocklisted, default: false, null: false
      t.boolean  :throttled, default: false, null: false
      t.boolean  :passed_captcha, default: false, null: false
      t.timestamps
    end

    add_index :sessions, :session_id, :unique => true
    add_index :sessions, :updated_at
  end
end
