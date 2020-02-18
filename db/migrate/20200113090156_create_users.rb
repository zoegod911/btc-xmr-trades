class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.text :crypted_password, null: false
      t.text :salt, null: false
      t.integer :role, default: 0, null: false
      t.integer :default_currency, default: 0, null: false
      t.text :pgp_public_key, null: false
      t.text :mnemonic, null: false
      t.string :invite_code

      t.timestamps
    end
    add_index :users, :role
    add_index :users, :default_currency
    add_index :users, :username, unique: true
    add_index :users, :mnemonic, unique: true

    require "#{Rails.root}/app/workers/crypto_ticker_worker"
    CryptoTickerWorker.new.perform
  end
end
