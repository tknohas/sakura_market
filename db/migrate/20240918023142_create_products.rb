class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.integer :price, null: false
      t.text :description
      t.boolean :is_private, null: false, default: false
      t.integer :sort_position

      t.timestamps
    end
    add_index :products, :sort_position, unique: true
  end
end
