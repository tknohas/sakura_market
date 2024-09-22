RSpec.describe 'Purchases', type: :system do
  let(:user) { create(:user, name: 'Alice') }
  let!(:cart) { create(:cart, user:) }
  let!(:product) { create(:product, name: 'ピーマン', price: 1_000, description: '苦味が少ないです。') }
  let!(:cart_item) { create(:cart_item, cart:, product:) }
  let!(:address) { create(:address, postal_code: '100-0005', prefecture: '東京都', city: '千代田区', street: '丸の内1丁目', user:) }

  before do
    user_login(user)
  end

  describe '購入確認画面' do
    it '商品情報が表示される' do
      visit new_purchase_path

      expect(page).to have_css 'h1', text: '購入確認'
      expect(page).to have_css 'img.product-image'
      expect(page).to have_content 'ピーマン'
      expect(page).to have_content '1,000円'
    end

    # TODO: 次の実装で送料が加算されるため、テスト追加
    it '小計、代引き手数料、消費税、合計金額が表示される' do
      visit new_purchase_path

      expect(page).to have_css 'h1', text: '購入確認'
      expect(page).to have_content '1,000円'
      expect(page).to have_content '300円'
      expect(page).to have_content '130円'
      expect(page).to have_content '1,430円'
    end

    it '配送先情報が表示される' do
      visit new_purchase_path

      expect(page).to have_css 'h1', text: '購入確認'
      expect(page).to have_content '100-0005'
      expect(page).to have_content '東京都'
      expect(page).to have_content '千代田区'
      expect(page).to have_content '丸の内1丁目'
      expect(page).to have_content 'Alice 様'
    end

    it '購入を完了できる' do
      visit new_purchase_path
      click_on '購入する'

      expect(page).to have_content '購入が完了しました。'
      expect(page).to have_css 'h1', text: '購入履歴'

      visit cart_path
      expect(page).to have_content 'カートには何も入っていません。'
      expect(user.cart.cart_items).to_not be_present
    end
  end

  describe '購入履歴' do
    let!(:purchase) { create(:purchase, user:) }
    let!(:product1) { create(:product, name: 'にんじん', price: 2_000, sort_position: 2) }
    let!(:purchase_item) { create(:purchase_item, purchase:, product:) }
    let!(:purchase_item1) { create(:purchase_item, purchase:, product: product1) }

    it '商品情報が表示される' do
      click_on '購入履歴'

      expect(page).to have_css 'h1', text: '購入履歴'
      expect(page).to have_content Purchase.last.id
      expect(page).to have_content 'ピーマン / にんじん'
      expect(page).to have_content '3,630円'
    end

    it '購入履歴詳細画面へ遷移する' do
      click_on '購入履歴'
      click_on 'ピーマン / にんじん'

      expect(page).to have_css 'h1', text: '購入履歴詳細'
    end
  end

  describe '購入履歴詳細' do
    let!(:purchase) { create(:purchase, user:, delivery_date: 3.business_days.after(Date.current), delivery_time: '8:00~12:00') }
    let!(:product1) { create(:product, name: 'にんじん', price: 2_000, sort_position: 2) }
    let!(:purchase_item) { create(:purchase_item, purchase:, product:) }
    let!(:purchase_item1) { create(:purchase_item, purchase:, product: product1) }

    it '商品情報が表示される' do
      visit purchase_path(purchase)

      expect(page).to have_css 'h1', text: '購入履歴詳細'
      expect(page).to have_css 'img.product-image'
      texts = all('tbody tr td').map(&:text)
      expect(texts).to eq ['ピーマン', '1,000円', 'にんじん', '2,000円']
      expect(page).to have_content '3,630円'
    end

    # TODO: 次の実装で送料が加算されるため、テスト追加
    it '小計、代引き手数料、消費税、合計金額が表示される' do
      visit purchase_path(purchase)

      expect(page).to have_css 'h1', text: '購入履歴詳細'
      expect(page).to have_content '3,000円'
      expect(page).to have_content '300円'
      expect(page).to have_content '330円'
      expect(page).to have_content '3,630円'
    end

    it '配送先情報が表示される' do
      visit purchase_path(purchase)

      expect(page).to have_css 'h1', text: '購入履歴詳細'
      expect(page).to have_content '100-0005'
      expect(page).to have_content '東京都'
      expect(page).to have_content '千代田区'
      expect(page).to have_content '丸の内1丁目'
      expect(page).to have_content 'Alice 様'
    end

    it '希望配達日時が表示される' do
      visit purchase_path(purchase)

      expect(page).to have_css 'h1', text: '購入履歴詳細'
      expect(page).to have_content purchase.delivery_date.strftime('%Y年%m月%d日')
      expect(page).to have_content '8:00~12:00'
    end
  end
end
