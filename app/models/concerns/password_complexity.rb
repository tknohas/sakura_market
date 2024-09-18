module PasswordComplexity
  extend ActiveSupport::Concern

  included do
    validate :password_complexity
  end

  def password_complexity
    if password.present? && !password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,20}$/)
      errors.add :password, 'は8文字以上20文字以下で半角英数字の小文字、大文字、数字が含まれている必要があります。'
    end
  end
end
