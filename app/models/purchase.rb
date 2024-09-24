class Purchase < ApplicationRecord
  belongs_to :user
  has_many :purchase_items, dependent: :destroy
  has_many :products, through: :purchase_items

  accepts_nested_attributes_for :purchase_items

  validates :delivery_time, presence: true
  validate :validate_delivery_date

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
    ((subtotal + cash_on_delivery_fee(subtotal) + calculate_shipping_fee) * TAX_RATE).floor
  end

  def tax_amount(subtotal)
    total_price(subtotal) - cash_on_delivery_fee(subtotal) - calculate_shipping_fee - subtotal
  end

  def ordered_products_price
    products.sum(:price) * total_quantity
  end

  SHIPPING_FEE_PER_TIER = 600
  SHIPPING_TIER_COUNT = 5

  def calculate_shipping_fee
    return SHIPPING_FEE_PER_TIER * (total_quantity.to_f / SHIPPING_TIER_COUNT).ceil
  end

  DELIVERY_TIME_OPTION = [
    '指定なし',
    '8:00~12:00',
    '12:00~14:00',
    '14:00~16:00',
    '16:00~18:00',
    '18:00~20:00',
    '20:00~21:00'
  ].map { |time| [time, time] }.freeze

  def delivery_time_option
    DELIVERY_TIME_OPTION
  end

  def earliest_allowed_date
    3.business_days.after(Date.current)
  end

  def latest_allowed_date
    14.business_days.after(Date.current)
  end

  def build_purchase_items_from_cart(cart)
    transaction do
      cart.cart_items.each do |cart_item|
        purchase_items.build(
          product_id: cart_item.product_id,
          quantity: cart_item.quantity
        )
      end
    end
  end

  private

  def validate_delivery_date
    return if delivery_date.blank?

    unless delivery_date.between?(earliest_allowed_date, latest_allowed_date)
      errors.add(:delivery_date, 'は3営業日（営業日: 月-金）から14営業日までの範囲で指定可能です。')
    end
  end

  def total_quantity
    return user.cart.item_count if user.cart.cart_items.present?
    purchase_items.sum(:quantity)
  end
end
