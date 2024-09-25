class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.string :code, null: false
      t.integer :point, null: false
      t.datetime :expires_at

      t.timestamps
    end
    add_index :coupons, :code, unique: true
  end
end
