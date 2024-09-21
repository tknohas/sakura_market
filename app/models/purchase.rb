class Purchase < ApplicationRecord
  belongs_to :user
  has_many :purchase_items, dependent: :destroy
  has_many :products, through: :purchase_items

  def cash_on_delivery_fee(subtotal)
    case subtotal
    when 0...10_000
      300
    when 10_000...30_000
      400
    when 30_000...100_000
      600
    else
      1_000
    end
  end

  TAX_RATE = 1.1

  def total_price(subtotal)
    ((subtotal + cash_on_delivery_fee((subtotal))) * TAX_RATE).floor
  end

  def tax_amount(subtotal)
    self.total_price(subtotal) - self.cash_on_delivery_fee(subtotal) - subtotal
  end

  def ordered_products_price
    products.sum(:price)
  end
end
