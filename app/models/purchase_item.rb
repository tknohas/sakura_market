class PurchaseItem < ApplicationRecord
  belongs_to :purchase
  belongs_to :product
  belongs_to :vendor

  validates :purchase_id, uniqueness: { scope: :product_id }

  def purchase_item_total_price
    product.price * quantity
  end
end
