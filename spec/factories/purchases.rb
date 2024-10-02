FactoryBot.define do
  factory :purchase do
    user { nil }
    delivery_time { '指定なし' }
    payment_method { :cash_on_delivery }
  end
end
