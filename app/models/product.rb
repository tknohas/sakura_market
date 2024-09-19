class Product < ApplicationRecord
  has_one_attached :image do |attachable|
    attachable.variant :small, resize_to_limit: [330, 219], preprocessed: true
    attachable.variant :large, resize_to_limit: [500, 333], preprocessed: true
  end

  with_options presence: true do
    validates :name
    validates :price
    validates :description
  end
  validates :sort_position, uniqueness: true

  scope :sorted_by, -> (sort_order) {
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
end
