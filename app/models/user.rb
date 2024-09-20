class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_one :cart, dependent: :destroy

  validates :name, presence: true
  validate :password_complexity

  include PasswordComplexity
end
