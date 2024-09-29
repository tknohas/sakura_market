RSpec.describe 'Products::Stocks', type: :system do
  let!(:vendor) { create(:vendor, name: 'アリスファーム', email: 'alicefarm@example.com', password: 'Abcd1234', created_at: '2024-09-28') }
  let!(:product) { create(:product, name: 'ピーマン', price: 1_000, description: '苦味が少ないです。') }

  before do
    vendor_login(vendor)
  end

  describe '商品一覧' do
    it '商品情報が表示される' do
      expect(page).to have_css 'h1', text: '商品一覧'
      expect(page).to have_current_path vendor_products_path
      expect(page).to have_css 'img.product-image'
      expect(page).to have_content 'ピーマン'
    end

    it '商品詳細画面へ遷移する' do
      click_on 'ピーマン'

      expect(page).to have_css 'h1', text: '商品詳細'
      expect(page).to have_current_path vendor_product_path(product)
    end
  end

  describe '商品詳細' do
    context '在庫が登録されている場合' do
      let!(:stock) { create(:stock, quantity: 100, vendor:, product:) }

      it '商品情報が表示される' do
        visit vendor_product_path(product)

        expect(page).to have_css 'h1', text: '商品詳細'
        expect(page).to have_content '在庫数: 100'
        expect(page).to have_css 'img.product-image'
        expect(page).to have_content 'ピーマン'
        expect(page).to have_content '苦味が少ないです。'
      end

      it '在庫編集画面へ遷移できる' do
        visit vendor_product_path(product)

        expect(page).to_not have_content '在庫登録'
        click_on '在庫編集'

        expect(page).to have_css 'h1', text: '在庫編集'
      end

      it 'トップ画面へ遷移する' do
        visit vendor_product_path(product)
        click_on 'トップ'

        expect(page).to have_css 'h1', text: '商品一覧'
        expect(page).to have_current_path vendor_products_path
      end
    end

    context '在庫が0の場合' do
      it '商品情報が表示される' do
        visit vendor_product_path(product)

        expect(page).to have_css 'h1', text: '商品詳細'
        expect(page).to have_content '在庫数: 0'
        expect(page).to have_css 'img.product-image'
        expect(page).to have_content 'ピーマン'
        expect(page).to have_content '苦味が少ないです。'
      end

      it '在庫登録画面へ遷移できる' do
        visit vendor_product_path(product)

        expect(page).to_not have_content '在庫編集'
        click_on '在庫登録'

        expect(page).to have_css 'h1', text: '在庫登録'
      end
    end
  end

  describe '在庫登録' do
    context 'フォームの入力値が正常な場合' do
      it '在庫を登録できる' do
        visit new_vendor_product_stock_path(product)

        fill_in 'stock_quantity', with: 50
        click_on '登録する'

        expect(page).to have_content '在庫を登録しました。'
        expect(page).to have_css 'h1', text: '商品詳細'
        expect(page).to have_content '在庫数: 50'
      end
    end

    context 'フォームの入力値が異常な場合' do
      it 'エラーメッセージが表示される' do
        visit new_vendor_product_stock_path(product)

        fill_in 'stock_quantity', with: '0'
        click_on '登録する'

        expect(page).to have_css 'h1', text: '在庫登録'
        expect(page).to have_content '在庫数は0より大きい値にしてください'
      end
    end

    it '前の画面へ遷移する' do
      visit vendor_product_path(product)

      click_on '在庫登録'
      expect(page).to have_css 'h1', text: '在庫登録'
      click_on '戻る'

      expect(page).to have_css 'h1', text: '商品詳細'
    end
  end

  describe '在庫編集' do
    let!(:stock) { create(:stock, quantity: 100, vendor:, product:) }

    context 'フォームの入力値が正常な場合' do
      it '在庫を更新できる' do
        visit edit_vendor_product_stock_path(product)

        fill_in 'stock_quantity', with: 200
        click_on '更新する'

        expect(page).to have_content '在庫を更新しました。'
        expect(page).to have_css 'h1', text: '商品詳細'
        expect(page).to have_content '在庫数: 200'
      end
    end

    context 'フォームの入力値が異常な場合' do
      it 'エラーメッセージが表示される' do
        visit edit_vendor_product_stock_path(product)

        fill_in 'stock_quantity', with: '0'
        click_on '更新する'

        expect(page).to have_css 'h1', text: '在庫編集'
        expect(page).to have_content '在庫数は0より大きい値にしてください'
      end
    end

    it '前の画面へ遷移する' do
      visit vendor_product_path(product)

      click_on '在庫編集'
      expect(page).to have_css 'h1', text: '在庫編集'
      click_on '戻る'

      expect(page).to have_css 'h1', text: '商品詳細'
    end
  end
end
