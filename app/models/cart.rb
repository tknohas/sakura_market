class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def product_in_cart?(product_id)
    cart_items.exists?(product_id:)
  end

  def merge_guest_cart(guest_cart)
    guest_cart.transaction do
      guest_cart.cart_items.each do |item|
        cart_items.create(product_id: item.product.id)
      end
    end
  end
end
