class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def product_in_cart?(product_id)
    cart_items.exists?(product_id:)
  end

  def merge_guest_cart(guest_cart)
    if guest_cart.present?
      guest_cart.transaction do
        guest_cart.cart_items.each do |item|
          existing_item = cart_items.find_by(product_id: item.product.id)

          if existing_item
            existing_item.update(quantity: existing_item.quantity + item.quantity)
          else
            cart_items.create(product_id: item.product.id, quantity: item.quantity)
          end
        end
      end
      guest_cart.destroy!
    end
  end

  def cart_items_destroy!
    cart_items.destroy_all
  end

  def item_count
    cart_items.sum(:quantity)
  end
end
