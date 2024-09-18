FactoryBot.define do
  factory :user do
    name { 'Alice' }
    sequence(:email) { |n| "alice#{n}@example.com" }
    password { 'Abcd1234' }
    confirmed_at { Time.current }
  end
end
