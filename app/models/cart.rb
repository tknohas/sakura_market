class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def product_in_cart?(product_id)
    cart_items.exists?(product_id:)
  end

  def merge_guest_cart(guest_cart)
    return unless guest_cart.present?

    begin
      guest_cart.transaction do
        vendor_id = cart_items.first&.vendor_id
        guest_cart.cart_items.each do |item|
          if vendor_id && vendor_id != item.vendor_id
            raise StandardError, '違う販売元の商品をカートに入れることはできません。'
          end

          existing_item = cart_items.find_by(product_id: item.product.id)
          if existing_item
            existing_item.update(quantity: existing_item.quantity + item.quantity)
          else
            cart_items.create(product_id: item.product.id, quantity: item.quantity, vendor_id: item.vendor.id)
          end
        end
      end
      guest_cart.destroy!
    rescue StandardError => e
      errors.add(:base, e.message)
    end
  end

  def cart_items_destroy!
    cart_items.destroy_all
  end

  def item_count
    cart_items.sum(:quantity)
  end

  def vendor_exists?(vendor_id)
    vendor_id.present? && cart_items.exists?(['vendor_id != ?', vendor_id])
  end
end
