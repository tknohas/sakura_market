class User < ApplicationRecord
  include Discard::Model

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

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
end
