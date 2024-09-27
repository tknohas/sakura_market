Admin.create!(email: 'admin@example.com', password: 'Abcd1234')

User.create!(name: 'Franky', email: 'franky@example.com', password: 'Abcd1234')
User.create!(name: 'Alice', email: 'alice@example.com', password: 'Abcd1234')
User.create!(name: 'Bob', email: 'bob@example.com', password: 'Abcd1234')

names = %w(にんじん ピーマン 玉ねぎ バナナ アボカド)
prices = [100, 1_000, 10_000, 200, 2_000]
(1..names.length).each do |n|
  Product.create!(
    name: names[n - 1],
    price: prices[n - 1],
    description: '商品説明です。',
    is_public: true,
    sort_position: n
  )
end

titles = %w(大きなアボカドを購入しました。 ジャガバターを作りました。 さくらんぼが届きました。)
contents = %w(サイズの大きなアボカドが売っていたので買ってみました。 家族でじゃがバターを作ってみました。 さくらんぼ)
(1..titles.length).each do |n|
  Diary.create!(user: User.find(n), title: titles[n - 1], content: contents[n - 1])
end

Coupon.create!(code: '1111-1111-1111', point: 100)
Coupon.create!(code: 'aaaa-aaaa-aaaa', point: 1000)
