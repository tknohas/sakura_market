class CartItemsController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    product = Product.find(params[:product_id])
    cart_item = current_cart.cart_items.find_or_initialize_by(product: product)

    if cart_item.new_record?
      cart_item.save!
      redirect_to cart_path, notice: '商品がカートに追加されました。'
    else
      redirect_to cart_path, alert: 'すでにカートに追加されています。'
    end
  end

  def destroy
    cart_item = current_cart.cart_items.find(params[:id])
    cart_item.destroy!
    redirect_to cart_path, notice: '商品を削除しました。'
  end
end
