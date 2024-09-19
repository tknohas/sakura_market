FactoryBot.define do
  factory :product do
    name { 'ピーマン' }
    price { 1000 }
    description { '商品説明' }
    is_public { true }
  end
end
