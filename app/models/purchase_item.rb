class PurchaseItem < ApplicationRecord
  belongs_to :purchase
  belongs_to :product

  validates :purchase_id, uniqueness: { scope: :product_id }
end
