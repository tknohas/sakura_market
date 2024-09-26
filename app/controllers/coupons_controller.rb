class CouponsController < ApplicationController
  def index
    @coupon_usages = current_user.coupon_usages.includes(:coupon).order(:id)
  end

  def apply
    coupon = Coupon.find_by(code: params[:code])

    if coupon&.valid_for_use?(current_user)
      current_user.coupon_usages.create(coupon: coupon)
      redirect_to coupons_path, notice: 'クーポンを適用しました。'
    else
      redirect_to products_path, alert: '無効なクーポンコードです。'
    end
  end
end
