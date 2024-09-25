FactoryBot.define do
  factory :comment do
    user { nil }
    diary { nil }
    content { '我が家もさくらんぼが届きました。' }
  end
end
