class Address < ApplicationRecord
  belongs_to :user

  with_options presence: true do
    validates :postal_code
    validates :prefecture
    validates :city
    validates :street
  end
  validates :prefecture, length: { maximum: 4 }, format: { with: /[都道府県]\z/, message: 'まで入力してください。' }
  validates :postal_code, length: { maximum: 8 }, format: { with: /\A\d{3}-\d{4}\z/, message: 'は123-4567のような形式で入力してください' }
end
