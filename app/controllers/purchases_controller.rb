class PurchasesController < ApplicationController
  def index
    @purchases = current_user.purchases.order(:id)
  end

  def new
    @purchase = current_user.purchases.build(product_ids: current_cart.product_ids)
  end

  def create
    @purchase = current_user.purchases.build(purchase_params)
    @purchase.transaction do
      if @purchase.save
        current_user.cart.cart_items_destroy!
        redirect_to purchases_path, notice: '購入が完了しました。'
      else
        render :new, alert: '購入に失敗しました。', status: :unprocessable_entity
      end
    end
  end

  def show
    @purchase = current_user.purchases.find(params[:id])
  end

  private

  def purchase_params
    params.require(:purchase).permit(product_ids: [])
  end
end
