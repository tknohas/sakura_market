class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :cart_id, uniqueness: { scope: :product_id }
  validates :quantity, presence: true,
            numericality: { greater_than: 0, less_than: 11, only_integer: true }

  def cart_item_total_price
    product.price * quantity
  end

  def add_quantity(new_quantity)
    if new_record?
      self.quantity = new_quantity
    else
      self.quantity += new_quantity
    end
  end
end
