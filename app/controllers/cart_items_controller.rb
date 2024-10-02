class CartItemsController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    product = Product.find(params[:product_id])
    cart_item = current_cart.cart_items.find_or_initialize_by(product:)
    vendor_id = params[:cart_item][:vendor_id].to_i

    if current_cart.vendor_exists?(vendor_id)
      redirect_to product_path(product), alert: '同じ販売元の商品のみカートに追加できます。'
      return
    end
    cart_item.vendor_id = vendor_id

    quantity = params[:cart_item][:quantity].to_i
    cart_item.add_quantity(quantity)

    if cart_item.save
      redirect_to cart_path, notice: '商品がカートに追加されました。'
    else
      redirect_to product_path(product), alert: cart_item.errors.full_messages.join(', ')
    end
  end

  def destroy
    cart_item = current_cart.cart_items.find(params[:id])
    cart_item.destroy!
    redirect_to cart_path, notice: '商品を削除しました。'
  end
end
