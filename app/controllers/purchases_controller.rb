class PurchasesController < ApplicationController
  def index
    @purchases = current_user.purchases.order(:id)
  end

  def new
    @purchase = current_user.purchases.build
    @purchase.build_purchase_items_from_cart(current_cart)
    @use_point = params[:use_point].to_i if params[:use_point].present?
  end

  def apply
    use_point = params[:use_point].to_i
    if current_user.total_point >= use_point
      redirect_to new_purchase_path(use_point:), notice: 'ポイントが適用されました。'
    else
      redirect_back fallback_location: new_purchase_path, alert: 'ポイントが不足しています。'
    end
  end

  def create
    @purchase = current_user.purchases.build(purchase_params)

    if @purchase.complete(current_cart)
      redirect_to purchases_path, notice: '購入が完了しました。'
    else
      flash.now[:alert] = @purchase.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @purchase = current_user.purchases.find(params[:id])
  end

  private

  def purchase_params
    params.require(:purchase).permit(:delivery_date, :delivery_time, :used_point, :payment_method)
  end
end
