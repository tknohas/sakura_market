class Coupon < ApplicationRecord
  has_many :coupon_usages, dependent: :destroy
  has_many :users, through: :coupon_usages

  validates :code, uniqueness: true, format: { with: /\A[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}\z/i }
  validates :point, numericality: { greater_than: 0 }
  with_options presence: true do
    validates :code
    validates :point
  end
  validate :expires_at_cannnot_be_in_the_past

  def valid_for_use?(user)
    active? && !user.used_coupon_code?(self)
  end

  def active?
    return true if expires_at.blank?
    expires_at >= Date.current.beginning_of_day
  end

  private

  def expires_at_cannnot_be_in_the_past
    if expires_at.present? && expires_at < Date.current.beginning_of_day
      errors.add(:expires_at, 'には本日以降の日付を選択してくだい。')
    end
  end
end
