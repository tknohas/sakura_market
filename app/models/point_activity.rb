class PointActivity < ApplicationRecord
  belongs_to :user

  with_options presence: true do
    validates :point_change
    validates :description
  end
end
