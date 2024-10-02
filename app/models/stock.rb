class Stock < ApplicationRecord
  belongs_to :product
  belongs_to :vendor

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :product_id, uniqueness: { scope: :vendor_id }
end
