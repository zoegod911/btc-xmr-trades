class CreateTraders < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :traders, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true
      t.string :slug, null: false
      t.integer :trust_score, default: 0, null: false
      t.string :wallet_id, null: false

      t.timestamps
    end
    add_index :traders, :trust_score
    add_index :traders, :slug, unique: true
  end
end
