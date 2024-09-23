class User < ApplicationRecord
  include Discard::Model

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_one :cart, dependent: :destroy
  has_one :address, dependent: :destroy
  has_many :purchases, dependent: :restrict_with_exception

  validates :name, presence: true
  validate :password_complexity

  default_scope -> { kept }

  include PasswordComplexity

  def active_for_authentication?
    super && !unavailable
  end

  def inactive_message
    unavailable ? :account_unavailable : super
  end

  def toggle_availability
    update(unavailable: !unavailable)
  end

  def availability_status
    unavailable ? '無効化' : '有効化'
  end
end
