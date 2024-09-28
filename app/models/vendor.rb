class Vendor < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true
  validate :password_complexity

  include PasswordComplexity
end
