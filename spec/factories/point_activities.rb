FactoryBot.define do
  factory :point_activity do
    user { nil }
    point_change { 100 }
    description { '雨の日キャンペーン' }
    expires_at { nil }
  end
end
