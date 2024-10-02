# Admin.create!(email: 'admin@example.com', password: 'Abcd1234')

# User.create!(name: 'Franky', nickname: '鉄人', email: 'franky@example.com', password: 'Abcd1234')
# User.create!(name: 'Alice', nickname: 'ありす', email: 'alice@example.com', password: 'Abcd1234')
# User.create!(name: 'Bob', nickname: 'bb', email: 'bob@example.com', password: 'Abcd1234')

names = %w(にんじん ピーマン 玉ねぎ バナナ アボカド)
prices = [100, 1_000, 10_000, 200, 2_000]
(1..names.length).each do |n|
  Product.create!(
    name: names[n - 1],
    price: prices[n - 1],
    description: '商品説明です。',
    is_private: false,
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

Vendor.create!(name: 'アリスファーム', email: 'alicefarm@example.com', password: 'Abcd1234')
Vendor.create!(name: 'フランキー食堂', email: 'frankycafeteria@example.com', password: 'Abcd1234')
Vendor.first.stocks.create!(quantity: 50, product: Product.first)
Vendor.first.stocks.create!(quantity: 50, product: Product.second)
Vendor.first.stocks.create!(quantity: 9, product: Product.third)
Vendor.second.stocks.create!(quantity: 45, product: Product.first)
Vendor.second.stocks.create!(quantity: 45, product: Product.second)
Vendor.second.stocks.create!(quantity: 45, product: Product.third)
