class ProductsController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    @cart = current_cart
    @product = Product.find(params[:id])
  end
end
