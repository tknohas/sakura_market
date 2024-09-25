class Diary < ApplicationRecord
  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :small, resize_to_limit: [330, 219], preprocessed: true
    attachable.variant :large, resize_to_limit: [500, 333], preprocessed: true
  end
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  with_options presence: true do
    validates :title
    validates :content
  end

  def like!(user)
    likes.find_or_create_by!(user: user)
  end

  def unlike!(user)
    likes.find_by!(user: user).destroy!
  end

  def liked_by?(user)
    likes.exists?(user_id: user.id)
  end
end
