RSpec.describe 'Purchases', type: :system do
  let(:user) { create(:user, name: 'Alice') }
  let!(:cart) { create(:cart, user:) }
  let!(:product) { create(:product, name: 'ピーマン', price: 1_000, description: '苦味が少ないです。') }
  let!(:cart_item) { create(:cart_item, cart:, product:, vendor:) }
  let!(:address) { create(:address, postal_code: '100-0005', prefecture: '東京都', city: '千代田区', street: '丸の内1丁目', user:) }
  let(:vendor) { create(:vendor, name: 'アリスファーム') }
  let!(:stock) { create(:stock, product:, vendor:, quantity: 10) }

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

    it '小計、送料、代引き手数料、消費税、合計金額が表示される' do
      visit new_purchase_path

      expect(page).to have_css 'h1', text: '購入確認'
      expect(page).to have_content '1,000円'
      expect(page).to have_content '600円'
      expect(page).to have_content '300円'
      expect(page).to have_content '190円'
      expect(page).to have_content '2,090円'
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

      visit product_path(product)
      find('#cart_item_vendor_id').select('アリスファーム (在庫: 9)')
      expect(Stock.last.quantity).to eq 9
    end

    context 'ポイントを使用する場合' do
      let!(:coupon) { create(:coupon, point: 1000) }
      let!(:coupon_usage) { create(:coupon_usage, user:, coupon:) }

      it 'ポイントを適用できる' do
        visit new_purchase_path

        fill_in 'use_point', with: 900

        click_on '適用'

        expect(page).to have_css 'h1', text: '購入確認'
        expect(page).to have_content '1,000円'  # 小計
        expect(page).to have_content '900円'    # 使用ポイント
        expect(page).to have_content '100円'    # ポイント使用後小計
        expect(page).to have_content '600円'    # 送料
        expect(page).to have_content '300円'    # 代引き手数料
        expect(page).to have_content '100円'    # 消費税
        expect(page).to have_content '1,100円'  # 合計

        expect(page).to have_content '使用可能ポイント: 100'
        expect(page).to have_content '適用ポイント: 900'
      end

      it '所持ポイント以上を適用するとエラーメッセージが表示される' do
        visit new_purchase_path

        fill_in 'use_point', with: 1001

        click_on '適用'

        expect(page).to have_css 'h1', text: '購入確認'
        expect(page).to have_content 'ポイントが不足しています。'
      end
    end

    context '在庫より商品数が多い場合' do
      let!(:stock) { create(:stock, product:, vendor:, quantity: 9) }
      let!(:cart_item) { create(:cart_item, cart:, product:, vendor:, quantity: 10) }

      it '購入できない' do
        visit new_purchase_path
        click_on '購入する'

        expect(page).to have_css 'h1', text: '購入確認'
        expect(page).to have_content '「ピーマン」の在庫が不足しています'
      end
    end
  end

  describe '購入履歴' do
    let!(:purchase) { create(:purchase, user:) }
    let!(:product1) { create(:product, name: 'にんじん', price: 2_000, sort_position: 2) }
    let!(:purchase_item) { create(:purchase_item, purchase:, product:, vendor:) }
    let!(:purchase_item1) { create(:purchase_item, purchase:, product: product1, vendor:) }

    it '商品情報が表示される' do
      click_on '購入履歴'

      expect(page).to have_css 'h1', text: '購入履歴'
      expect(page).to have_content Purchase.last.id
      expect(page).to have_content 'ピーマン / にんじん'
      expect(page).to have_content purchase.created_at.strftime('%Y年%m月%d日')
      expect(page).to have_content '代金引換'
    end

    it '購入履歴詳細画面へ遷移する' do
      click_on '購入履歴'
      click_on 'ピーマン / にんじん'

      expect(page).to have_css 'h1', text: '購入履歴詳細'
      expect(page).to have_content '4,290円'
    end

    it 'トップ画面へ遷移する' do
      click_on '購入履歴'
      click_on 'トップ'

      expect(page).to have_css 'h1', text: '日記一覧'
    end
  end

  describe '購入履歴詳細' do
    let!(:purchase) { create(:purchase, user:, delivery_date: 3.business_days.after(Date.current), delivery_time: '8:00~12:00') }
    let!(:product1) { create(:product, name: 'にんじん', price: 10_000, sort_position: 2) }
    let!(:purchase_item) { create(:purchase_item, purchase:, product:, vendor:) }
    let!(:purchase_item1) { create(:purchase_item, purchase:, product: product1, quantity: 2, vendor:) }

    it '商品情報が表示される' do
      visit purchase_path(purchase)

      expect(page).to have_css 'h1', text: '購入履歴詳細'
      expect(page).to have_css 'img.product-image'
      texts = all('tbody tr').map(&:text)
      expect(texts[0]).to eq "ピーマン\nアリスファーム\n1,000円\n1\n1,000円"
      expect(texts[1]).to eq "にんじん\nアリスファーム\n10,000円\n2\n20,000円"
    end

    it '小計、送料、代引き手数料、消費税、合計金額が表示される' do
      visit purchase_path(purchase)

      expect(page).to have_css 'h1', text: '購入履歴詳細'
      expect(page).to have_content '21,000円'
      expect(page).to have_content '600円'
      expect(page).to have_content '400円'
      expect(page).to have_content '2,200円'
      expect(page).to have_content '24,200円'
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

  context 'ポイントを使用して購入した場合' do
    let!(:coupon) { create(:coupon, point: 1000) }
    let!(:coupon_usage) { create(:coupon_usage, user:, coupon:) }

    it '支払い情報にポイントが反映されている' do
      visit new_purchase_path

      fill_in 'use_point', with: 900

      click_on '適用'
      expect(page).to have_content 'ポイントが適用されました。'

      click_on '購入する'
      click_on 'ピーマン'

      expect(page).to have_css 'h1', text: '購入履歴詳細'
      expect(page).to have_content '1,000円'  # 小計
      expect(page).to have_content '900円'    # 使用ポイント
      expect(page).to have_content '100円'    # ポイント使用後小計
      expect(page).to have_content '600円'    # 送料
      expect(page).to have_content '300円'    # 代引き手数料
      expect(page).to have_content '100円'    # 消費税
      expect(page).to have_content '1,100円'  # 合計
    end

    it 'ポイント使用後に使用可能ポイントが減少している' do
      visit new_purchase_path

      fill_in 'use_point', with: 900

      click_on '適用'
      expect(page).to have_content 'ポイントが適用されました。'

      click_on '購入する'

      visit product_path(product)
      find('#cart_item_vendor_id').select('アリスファーム')
      click_on 'カートに追加'
      click_on '購入確認'

      expect(page).to have_css 'h1', text: '購入確認'
      expect(page).to have_content '使用可能ポイント: 100'
    end
  end
end
