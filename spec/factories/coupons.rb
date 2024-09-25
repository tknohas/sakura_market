FactoryBot.define do
  factory :coupon do
    code { 'Abcd-12fd-1hbw' }
    point { 100 }
    expires_at { nil }
  end
end
