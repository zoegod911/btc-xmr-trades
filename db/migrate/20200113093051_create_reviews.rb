class CreateReviews < ActiveRecord::Migration[6.0]
  def change
    create_table :reviews, id: :uuid do |t|
      t.references :trade, type: :uuid, null: false, foreign_key: true
      t.uuid :reviewer_id, foreign_key: true, null: false
      t.uuid :reviewee_id, foreign_key: true, null: false
      t.text :content, null: false
      t.boolean :trusted, null: false

      t.timestamps
    end
    add_index :reviews, :reviewer_id
    add_index :reviews, :reviewee_id
    add_index :reviews, :trusted
  end
end
