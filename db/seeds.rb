Admin.create!(email: 'admin@example.com', password: 'Abcd1234')

User.create!(name: 'Franky', email: 'franky@example.com', password: 'Abcd1234')

names = %w(にんじん ピーマン 玉ねぎ)
prices = [100, 1_000, 10_000]
(1..3).each do |n|
  Product.create!(
    name: names[n - 1],
    price: prices[n - 1],
    description: '商品説明です。',
    is_public: true,
    sort_position: n
  )
end
