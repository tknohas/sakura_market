class Product < ApplicationRecord
  has_one_attached :image do |attachable|
    attachable.variant :small, resize_to_limit: [120, 80], preprocessed: true
    attachable.variant :middle, resize_to_limit: [330, 219], preprocessed: true
    attachable.variant :large, resize_to_limit: [500, 333], preprocessed: true
  end
  has_many :cart_items, dependent: :destroy
  has_many :carts, through: :cart_items
  has_many :stocks, dependent: :destroy
  has_many :vendors, through: :stocks

  with_options presence: true do
    validates :name
    validates :price
    validates :description
  end
  validates :sort_position, uniqueness: true
  validates :name, length: { maximum: 20 }
  validates :price, numericality: { only_integer: true }
  validates :description, length: { maximum: 600 }

  scope :sorted_by, ->(sort_order) {
    case sort_order
    when 'newest'
      order(created_at: :desc)
    when 'lowest_price'
      order(:price)
    when 'highest_price'
      order(price: :desc)
    when 'sort_position'
      order(:sort_position)
    else
      order(:id)
    end
  }

  def vendor_stock_info(product)
    vendors.map do |vendor|
      stock = vendor.stocks.find_by(product:)
      ["#{vendor.name} (在庫: #{stock ? stock.quantity : '不明'})", vendor.id]
    end
  end
end
