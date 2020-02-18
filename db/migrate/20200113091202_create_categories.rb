class CreateCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :categories, id: :uuid do |t|
      t.string :title
      t.string :ancestry
      t.string :slug
      t.integer :ancestry_depth

      t.timestamps
    end
    add_index :categories, :title
    add_index :categories, :slug
  end
end
