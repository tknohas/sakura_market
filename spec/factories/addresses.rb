FactoryBot.define do
  factory :address do
    postal_code { '100-0005' }
    prefecture { '東京都' }
    city { '千代田区' }
    street { '丸の内1丁目' }
    building { nil }
  end
end
