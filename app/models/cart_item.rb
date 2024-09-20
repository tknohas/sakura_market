class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :cart_id, uniqueness: { scope: :product_id }
end
