class CouponUsage < ApplicationRecord
  after_create :record_earn_point

  belongs_to :user
  belongs_to :coupon

  validates :user_id, uniqueness: { scope: :coupon_id }

  private

  def record_earn_point
    attributes = {
    point_change: coupon.point,
    description: "クーポンによるポイント獲得"
    }

    case coupon.code
    when /\A\d{4}-\d{4}-\d{4}\z/
      attributes[:expires_at] = Date.current.next_month
    when /\A[a-z]{4}-[a-z]{4}-[a-z]{4}\z/
      attributes[:expires_at] = Date.current.since(7.days)
    when /\A[A-Z]{4}-[A-Z]{4}-[A-Z]{4}\z/
      attributes[:expires_at] = Date.current.end_of_month
    end

    user.point_activities.create!(attributes)
  end
end
