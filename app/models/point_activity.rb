class PointActivity < ApplicationRecord
  belongs_to :user

  with_options presence: true do
    validates :point_change
    validates :description
  end
  validates :point_change, numericality: { only_integer: true }
  validates :description, length: { maximum: 60 }
end
