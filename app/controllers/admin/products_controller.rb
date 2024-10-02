class Admin::ProductsController < Admin::ApplicationController
  before_action :set_product, only: %i[show edit update destroy]

  def index
    @sort_order = params[:sort_order] || session[:sort_order] || 'sort_position'
    session[:sort_order] = @sort_order
    @products = Product.includes(:image_attachment).sorted_by(@sort_order).order(:id)
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to admin_products_path, notice: '登録に成功しました。'
    else
      flash.now[:alert] = '登録に失敗しました。'
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def edit; end

  def update
    if @product.update(product_params)
      redirect_to admin_products_path, notice: '更新に成功しました。'
    else
      flash.now[:alert] = '更新に失敗しました。'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy!
    redirect_to admin_products_path, notice: '削除に成功しました。'
  end

  private

  def product_params
    params.require(:product).permit(:name, :price, :description, :is_private, :image, :sort_position)
  end

  def set_product
    @product = Product.find(params[:id])
  end
end
