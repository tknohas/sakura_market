class Vendor < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :stocks, dependent: :destroy
  has_many :products, through: :stocks

  validates :name, presence: true, length: { maximum: 50 }
  validate :password_complexity

  include PasswordComplexity

  def stock_quantity_for(product)
    stocks.find_by(product:)&.quantity || 0
  end
end
