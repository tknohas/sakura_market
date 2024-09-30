class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product
  belongs_to :vendor

  validates :cart_id, uniqueness: { scope: :product_id }
  validates :quantity, presence: true,
            numericality: { greater_than: 0, less_than: 11, only_integer: true }
  validates :vendor_id, presence: true
  validate :validate_stock_sufficiency

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

  private

  def validate_stock_sufficiency
    return false if vendor.nil?
    stock = vendor.stocks.find_by(product:)
    if stock.present? && stock.quantity < quantity
      errors.add(:base, '在庫数を超える商品数を追加できません。')
    end
  end
end
