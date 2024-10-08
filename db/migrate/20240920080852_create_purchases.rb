class CreatePurchases < ActiveRecord::Migration[7.1]
  def change
    create_table :purchases do |t|
      t.references :user, null: false, foreign_key: true
      t.date :delivery_date
      t.string :delivery_time, null: false
      t.integer :used_point
      t.integer :payment_method, null: false, default: 0

      t.timestamps
    end
  end
end
