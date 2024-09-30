RSpec.describe 'Products', type: :system do
  let!(:admin) { create(:admin) }
  let!(:product) { create(:product, name: 'ピーマン', price: 1_000, description: '苦味が少ないです。', sort_position: 1, created_at: '2024-01-01') }

  before do
    admin_login(admin)
  end

  describe '一覧画面' do
    let!(:highest_price_product) { create(:product, name: 'にんじん', price: 10_000, sort_position: 3, created_at: '2024-04-01') }
    let!(:lowest_price_product) { create(:product, name: '玉ねぎ', price: 100, sort_position: 2, created_at: '2024-07-01') }

    it '商品情報が表示される' do
      expect(page).to have_css 'h1', text: '商品一覧(管理画面)'
      expect(page).to have_css 'img.product-image'
      expect(page).to have_content 'ピーマン'
    end

    it '価格が安い順に並び替わる', :js do
      select '価格が安い順', from: 'sort_order'

      expect(page).to have_css 'h1', text: '商品一覧(管理画面)'
      expect(page).to have_select('sort_order', selected: '価格が安い順')
      products = all('div a p').map(&:text)
      expect(products).to eq ['玉ねぎ', 'ピーマン', 'にんじん']
    end

    it '価格が高い順に並び替わる', :js do
      select '価格が高い順', from: 'sort_order'

      expect(page).to have_css 'h1', text: '商品一覧(管理画面)'
      expect(page).to have_select('sort_order', selected: '価格が高い順')
      products = all('div a p').map(&:text)
      expect(products).to eq ['にんじん', 'ピーマン', '玉ねぎ']
    end

    it '表示順に並び替わる', :js do
      select '表示順', from: 'sort_order'

      expect(page).to have_css 'h1', text: '商品一覧(管理画面)'
      expect(page).to have_select('sort_order', selected: '表示順')
      products = all('div a p').map(&:text)
      expect(products).to eq ['ピーマン', '玉ねぎ', 'にんじん']
    end

    it '新着順に並び替わる', :js do
      select '新着順', from: 'sort_order'

      expect(page).to have_css 'h1', text: '商品一覧(管理画面)'
      expect(page).to have_select('sort_order', selected: '新着順')
      products = all('div a p').map(&:text)
      expect(products).to eq ['玉ねぎ', 'にんじん', 'ピーマン']
    end

    it '商品登録画面へ遷移する' do
      click_on '商品登録画面'
      expect(page).to have_css 'h1', text: '商品登録'
    end

    it '商品詳細画面へ遷移する' do
      click_on 'ピーマン'
      expect(page).to have_css 'h1', text: '商品詳細(管理画面)'
    end
  end

  describe '商品登録画面' do
    context 'フォームの入力値が正常な場合' do
      it '商品情報を登録できる' do
        visit new_admin_product_path

        fill_in 'product_name', with: 'トマト'
        fill_in 'product_price', with: 100
        fill_in 'product_description', with: '酸味と甘味のバランスが絶妙です。'
        attach_file 'product_image', file_fixture('test_image.jpg')
        find('#product_is_public').check
        fill_in 'product_sort_position', with: 2
        click_on '登録'

        expect(page).to have_content '登録に成功しました'
        expect(page).to have_css 'h1', text: '商品一覧(管理画面)'
        expect(page).to have_content 'トマト'
        expect(page).to have_css 'img.product-image'
        expect(Product.last.is_public).to eq true
        expect(Product.last.sort_position).to eq 2
      end
    end

    context 'フォームの入力値が異常な場合' do
      it 'エラーメッセージが表示される' do
        visit new_admin_product_path

        fill_in 'product_name', with: ''
        fill_in 'product_price', with: nil
        fill_in 'product_description', with: ''
        fill_in 'product_sort_position', with: 1
        click_on '登録'

        expect(page).to have_css 'h1', text: '商品登録'
        expect(page).to have_content '商品名を入力してください'
        expect(page).to have_content '価格を入力してください'
        expect(page).to have_content '商品説明を入力してください'
        expect(page).to have_content '表示順はすでに存在します'
      end
    end

    it '戻るボタンで一覧画面に戻る' do
      visit admin_products_path

      click_on '商品登録画面'
      click_on '戻る'

      expect(page).to have_css 'h1', text: '商品一覧(管理画面)'
    end
  end

  describe '商品詳細画面' do
    it '商品情報が表示される' do
      visit admin_product_path(product)

      expect(page).to have_css 'h1', text: '商品詳細(管理画面)'
      expect(page).to have_css 'img.product-image'
      expect(page).to have_content 'ピーマン'
      expect(page).to have_content 100
      expect(page).to have_content '苦味が少ないです。'
    end

    it '商品を削除できる', :js do
      expect(page).to have_content 'ログインしました。' # NOTE: テストが落ちてしまうため記載
      visit admin_product_path(product)

      expect(page).to have_css 'h1', text: '商品詳細(管理画面)'
      expect{
        click_on '削除'
        expect(page.accept_confirm).to eq '本当に削除しますか？'
        expect(page).to have_content '削除に成功しました。'
      }.to change(Product, :count).by(-1)
    end

    it 'トップ画面へ遷移する' do
      visit admin_product_path(product)
      click_on 'トップ'
      expect(page).to have_css 'h1', text: '商品一覧(管理画面)'
    end

    it '前の画面へ戻る' do
      visit admin_products_path

      click_on 'ピーマン'
      click_on '戻る'

      expect(page).to have_css 'h1', text: '商品一覧(管理画面)'
    end

    it '編集画面へ遷移する' do
      visit admin_product_path(product)
      click_on '編集'
      expect(page).to have_css 'h1', text: '商品編集'
    end
  end

  describe '商品編集画面' do
    context 'フォームの入力値が正常な場合' do
      it '商品情報を編集できる' do
        visit edit_admin_product_path(product)

        fill_in 'product_name', with: 'みかん'
        fill_in 'product_price', with: 2_000
        fill_in 'product_description', with: 'ココヤシ村で生産されました。'
        attach_file 'product_image', file_fixture('test_image.jpg')
        find('#product_is_public').uncheck
        fill_in 'product_sort_position', with: 1
        click_on '変更'

        expect(page).to have_content '更新に成功しました'
        expect(page).to have_css 'h1', text: '商品一覧(管理画面)'
        expect(page).to have_content 'みかん'
        expect(page).to have_css 'img.product-image'
        expect(Product.last.is_public).to eq false
        expect(Product.last.sort_position).to eq 1
      end
    end

    context 'フォームの入力値が異常な場合' do
      it 'エラーメッセージが表示される' do
        visit edit_admin_product_path(product)

        fill_in 'product_name', with: ''
        fill_in 'product_price', with: ''
        fill_in 'product_description', with: ''
        click_on '変更'

        expect(page).to have_css 'h1', text: '商品編集'
        expect(page).to have_content '商品名を入力してください'
        expect(page).to have_content '価格を入力してください'
        expect(page).to have_content '商品説明を入力してください'
      end
    end

    it 'トップ画面へ遷移する' do
      visit edit_admin_product_path(product)
      click_on 'トップ'
      expect(page).to have_css 'h1', text: '商品一覧(管理画面)'
    end

    it '前の画面へ戻る' do
      visit admin_product_path(product)

      click_on '編集'
      click_on '戻る'

      expect(page).to have_css 'h1', text: '商品詳細(管理画面)'
    end
  end
end
