FactoryBot.define do
  factory :vendor do
    name { 'アリスファーム' }
    sequence(:email) { |n| "alicefarm#{n}@example.com" }
    password { 'Abcd1234' }
    password_changed { false }
  end
end
