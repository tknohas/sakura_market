class CreateCouponUsages < ActiveRecord::Migration[7.1]
  def change
    create_table :coupon_usages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :coupon, null: false, foreign_key: true

      t.timestamps
    end
    add_index :coupon_usages, [:user_id, :coupon_id], unique: true
  end
end
