class User < ApplicationRecord
  include Discard::Model

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_one_attached :image do |attachable|
    attachable.variant :small, resize_to_limit: [50, 50], preprocessed: true
    attachable.variant :large, resize_to_limit: [70, 70], preprocessed: true
  end
  has_one :cart, dependent: :destroy
  has_one :address, dependent: :destroy
  has_many :purchases, dependent: :restrict_with_exception
  has_many :diaries, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :coupon_usages, dependent: :destroy
  has_many :coupons, through: :coupon_usages
  has_many :point_activities, dependent: :destroy

  validates :name, presence: true
  validates :nickname, presence: true
  validate :password_complexity

  default_scope -> { kept }

  include PasswordComplexity

  def active_for_authentication?
    super && canceled_at.nil? && !unavailable
  end

  def inactive_message
    if canceled_at.present?
      :canceled_user
    elsif unavailable
      :account_unavailable
    else
      super
    end
  end

  def toggle_availability
    update(unavailable: !unavailable)
  end

  def availability_status
    unavailable ? '無効化' : '有効化'
  end

  def canceled?
    canceled_at.present?
  end

  def used_coupon_code?(coupon)
    coupon_usages.exists?(coupon: coupon)
  end

  def total_point
    point_activities.sum(:point_change)
  end

  def line_items_checkout
    cart.cart_items.map do |cart_item|
      {
        quantity: cart_item.quantity,
        price_data: {
          currency: 'jpy',
          unit_amount: cart_item.calculate_tax_inclusive_price,
          product_data: {
            name: cart_item.product.name,
            metadata: {
              product_id: cart_item.product_id,
              vendor_id: cart_item.vendor_id
            }
          }
        }
      }
    end
  end
end
