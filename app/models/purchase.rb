class Purchase < ApplicationRecord
  after_create :record_used_point

  belongs_to :user
  has_many :purchase_items, dependent: :destroy
  has_many :products, through: :purchase_items

  validates :delivery_time, presence: true
  validate :validate_delivery_date

  enum payment_method: { cash_on_delivery: 0, card: 1 }

  def cash_on_delivery_fee(adjusted_subtotal)
    case adjusted_subtotal
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

  def adjusted_subtotal(subtotal, use_point)
    return 0 if use_point > subtotal
    return subtotal - use_point if used_point
    return subtotal - use_point if user.total_point >= use_point
    return subtotal
  end

  def total_price(adjusted_subtotal)
    ((adjusted_subtotal + cash_on_delivery_fee(adjusted_subtotal) + calculate_shipping_fee) * TAX_RATE).floor
  end

  def tax_amount(adjusted_subtotal)
    total_price(adjusted_subtotal) - cash_on_delivery_fee(adjusted_subtotal) - calculate_shipping_fee - adjusted_subtotal
  end

  def total_price_for_card(subtotal)
    ((subtotal + calculate_shipping_fee) * TAX_RATE).floor
  end

  def tax_amount_for_card(subtotal)
    total_price_for_card(subtotal) - calculate_shipping_fee - subtotal
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
          quantity: cart_item.quantity,
          vendor_id: cart_item.vendor_id
        )
      end
    end
  end

  def complete(cart)
    return false unless valid?
    transaction do
      save!
      cart.cart_items.each do |cart_item|
        purchase_items.create!(
          product: cart_item.product,
          vendor: cart_item.vendor,
          quantity: cart_item.quantity
        )
        update_stock_after_purchase(cart_item)
        cart.cart_items_destroy!
      end
    end
    true
  rescue ActiveRecord::RecordInvalid
    false
  end


  def update_stock_after_card_purchase(product, vendor, line_item_quantity)
    stock = product.stocks.lock.find_by(vendor:)
    new_stock_quantity = stock.quantity - line_item_quantity
    stock.update!(quantity: new_stock_quantity)
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

  def record_used_point
    if used_point.present? && used_point > 0
      user.point_activities.create!(
        point_change: -used_point,
        description: '購入時のポイント使用',
      )
    end
  end

  def update_stock_after_purchase(cart_item)
    stock = cart_item.product.stocks.lock.find_by(vendor: cart_item.vendor)
    if stock
      if stock.quantity >= cart_item.quantity
        new_stock_quantity = stock.quantity - cart_item.quantity
        stock.update!(quantity: new_stock_quantity)
      else
        errors.add(:base, "「#{cart_item.product.name}」の在庫が不足しています")
        raise ActiveRecord::RecordInvalid.new(self)
      end
    end
  end
end
