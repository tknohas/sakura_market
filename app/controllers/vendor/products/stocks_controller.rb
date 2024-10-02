class Vendor::Products::StocksController < Vendor::ApplicationController
  before_action :set_product, only: %i[new create edit update]
  before_action :set_stock, only: %i[edit update]

  def new
    @stock = current_vendor.stocks.build
  end

  def create
    @stock = current_vendor.stocks.find_or_initialize_by(product: @product)
    @stock.assign_attributes(stock_params)
    if @stock.save
      redirect_to vendor_product_path(@product), notice: '在庫を登録しました。'
    else
      flash.now[:alert] = '在庫の登録に失敗しました。'
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @stock.update(stock_params)
      redirect_to vendor_product_path(@product), notice: '在庫を更新しました。'
    else
      flash.now[:alert] = '在庫の更新に失敗しました。'
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def stock_params
    params.require(:stock).permit(:quantity)
  end

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_stock
    @stock = current_vendor.stocks.find_by(product: @product)
  end
end
