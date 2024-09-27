class CouponUsage < ApplicationRecord
  after_create :record_earn_point
  
  belongs_to :user
  belongs_to :coupon

  validates :user_id, uniqueness: { scope: :coupon_id }

  private

  def record_earn_point
    user.point_activities.create!(
      point_change: coupon.point,
      description: "クーポンによるポイント獲得",
    )
  end
end
