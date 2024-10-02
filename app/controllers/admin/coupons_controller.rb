class Admin::CouponsController < Admin::ApplicationController
  before_action :set_coupon, only: %i[show edit update destroy]

  def index
    @coupons = Coupon.order(:id)
  end

  def new
    @coupon = Coupon.new
  end

  def create
    @coupon = Coupon.new(coupon_params)
    if @coupon.save
      redirect_to admin_coupons_path, notice: 'クーポンを作成しました。'
    else
      render :new, alert: 'クーポンの作成に失敗しました。', status: :unprocessable_entity
    end
  end

  def show; end

  def edit; end

  def update
    if @coupon.update(coupon_params)
      redirect_to admin_coupons_path, notice: 'クーポンを更新しました。'
    else
      render :edit, alert: 'クーポンの更新に失敗しました。', status: :unprocessable_entity
    end
  end

  def destroy
    @coupon.destroy!
    redirect_to admin_coupons_path, notice: 'クーポンを削除しました。'
  end

  private

  def coupon_params
    params.require(:coupon).permit(:code, :point, :expires_at)
  end

  def set_coupon
    @coupon = Coupon.find(params[:id])
  end
end
