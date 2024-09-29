class CreateStocks < ActiveRecord::Migration[7.1]
  def change
    create_table :stocks do |t|
      t.references :product, null: false, foreign_key: true
      t.references :vendor, null: false, foreign_key: true
      t.integer :quantity, null: false, default: false

      t.timestamps
    end
    add_index :stocks, [:product_id, :vendor_id], unique: true
  end
end
