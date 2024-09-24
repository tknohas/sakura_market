FactoryBot.define do
  factory :diary do
    user { nil }
    title { 'さくらんぼが届きました。' }
    content { '家族みんなで食べる予定です。' }
  end
end
