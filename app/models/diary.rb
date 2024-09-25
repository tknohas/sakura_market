class Diary < ApplicationRecord
  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :small, resize_to_limit: [330, 219], preprocessed: true
    attachable.variant :large, resize_to_limit: [500, 333], preprocessed: true
  end
  has_many :comments, dependent: :destroy

  with_options presence: true do
    validates :title
    validates :content
  end
end
