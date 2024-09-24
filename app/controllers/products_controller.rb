class ProductsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @sort_order = params[:sort_order] || session[:sort_order] || 'sort_position'
    session[:sort_order] = @sort_order
    @products = Product.includes(:image_attachment).sorted_by(@sort_order).order(:id)
  end

  def show
    @cart = current_cart
    @product = Product.find(params[:id])
  end
end
