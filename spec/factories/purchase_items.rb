FactoryBot.define do
  factory :purchase_item do
    purchase { nil }
    product { nil }
    quantity { 1 }
  end
end
