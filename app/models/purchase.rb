class Purchase < ApplicationRecord
  belongs_to :user
  has_many :purchase_items, dependent: :destroy
  has_many :products, through: :purchase_items

  validate :not_weekend
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
    ((subtotal + cash_on_delivery_fee((subtotal))) * TAX_RATE).floor
  end

  def tax_amount(subtotal)
    total_price(subtotal) - cash_on_delivery_fee(subtotal) - subtotal
  end

  def ordered_products_price
    products.sum(:price)
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

  private

  def not_weekend
    if delivery_date.present? && delivery_date.on_weekend?
      errors.add(:delivery_date, 'に土曜日および日曜日は選択できません。')
    end
  end

  def validate_delivery_date
    return if delivery_date.blank?

    unless delivery_date.between?(earliest_allowed_date, latest_allowed_date)
      errors.add(:delivery_date, 'は3営業日（営業日: 月-金）から14営業日までの範囲で指定可能です。')
    end
  end
end
