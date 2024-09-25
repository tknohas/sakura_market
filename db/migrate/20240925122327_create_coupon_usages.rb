class CreateCouponUsages < ActiveRecord::Migration[7.1]
  def change
    create_table :coupon_usages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :coupon, null: false, foreign_key: true
      t.datetime :used_at

      t.timestamps
    end
  end
end
