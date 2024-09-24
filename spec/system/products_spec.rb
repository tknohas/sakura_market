RSpec.describe 'Products', type: :system do
  let!(:product) { create(:product, name: 'ピーマン', price: 1_000, description: '苦味が少ないです。', sort_position: 1, created_at: '2024-01-01') }

  describe '商品詳細画面' do
    it '商品情報が表示される' do
      visit product_path(product)

      expect(page).to have_css 'h1', text: '商品詳細'
      expect(page).to have_css 'img.product-image'
      expect(page).to have_content 'ピーマン'
      expect(page).to have_content 100
      expect(page).to have_content '苦味が少ないです。'
    end

    it '前の画面へ戻る' do
      visit root_path
      click_on 'ピーマン'
      click_on '戻る'

      expect(page).to have_css 'h1', text: '商品一覧'
    end
  end

  describe 'カート(ログインユーザー)' do
    let(:user) { create(:user) }

    before do
      user_login(user)
    end

    context 'カートに同じ商品がない場合' do
      it 'カートに商品を追加できる' do
        visit product_path(product)
        click_on 'カートに追加'

        expect(page).to have_css 'h1', text: 'カート'
        expect(page).to have_css 'img.product-image'
        expect(page).to have_content 'ピーマン'
        expect(page).to have_content '1,000円'
        expect(page).to have_content '1'
        expect(CartItem.last.quantity).to eq 1
      end
    end

    context 'カートにすでに同じ商品がある場合' do
      let!(:cart) { create(:cart, user:) }
      let!(:cart_item) { create(:cart_item, cart:, product:) }

      it 'カートに商品を追加できる' do
        visit product_path(product)
        click_on 'カートに追加'

        expect(page).to have_content '商品がカートに追加されました。'
        expect(page).to have_css 'h1', text: 'カート'
        expect(page).to have_css 'img.product-image'
        expect(page).to have_content 'ピーマン'
        expect(page).to have_content '1,000円'
        expect(page).to have_content '2'
        expect(page).to have_content '2,000円'
        expect(CartItem.last.quantity).to eq 2
      end
    end

    it 'カートの商品を削除できる', :js do
      visit product_path(product)
      click_on 'カートに追加'
      expect(page).to have_css 'h1', text: 'カート'

      expect {
        click_on '削除'
        expect(page.accept_confirm).to eq '本当に削除しますか？'
        expect(page).to have_content '商品を削除しました。'
      }.to change(CartItem, :count).by(-1)
    end

    it 'トップ画面へ遷移する' do
      visit cart_path
      click_on '買い物を続ける'

      expect(page).to have_current_path root_path
    end
  end

  describe 'カート(セッション)' do
    let(:user) { create(:user) }

    context 'カートに同じ商品がない場合' do
      it 'カートに商品を追加できる' do
        visit product_path(product)
        click_on 'カートに追加'

        expect(page).to have_css 'h1', text: 'カート'
        expect(page).to have_css 'img.product-image'
        expect(page).to have_content 'ピーマン'
        expect(page).to have_content '1,000円'
      end
    end

    context 'カートにすでに同じ商品がある場合' do
      it 'カートに商品を追加できる' do
        visit product_path(product)
        click_on 'カートに追加'
        visit product_path(product)
        click_on 'カートに追加'

        expect(page).to have_content '商品がカートに追加されました。'
        expect(page).to have_css 'h1', text: 'カート'
        expect(page).to have_css 'img.product-image'
        expect(page).to have_content 'ピーマン'
        expect(page).to have_content '1,000円'
        expect(page).to have_content '2'
        expect(page).to have_content '2,000円'
        expect(CartItem.last.quantity).to eq 2
      end
    end

    it 'カートの商品を削除できる', :js do
      visit product_path(product)
      click_on 'カートに追加'
      expect(page).to have_css 'h1', text: 'カート'

      expect {
        click_on '削除'
        expect(page.accept_confirm).to eq '本当に削除しますか？'
        expect(page).to have_content '商品を削除しました。'
      }.to change(CartItem, :count).by(-1)
    end

    it 'カートの商品をログイン後も引き継ぐことができる(ログイン時)' do
      visit product_path(product)
      click_on 'カートに追加'
      expect(Cart.last.cart_items).to be_present

      user_login(user)
      expect(page).to have_content 'ログインしました'

      click_on 'カート'
      expect(page).to have_css 'h1', text: 'カート'
      expect(page).to have_content 'ピーマン'
      expect(page).to have_content '1,000円'
    end

    it 'カートの商品をログイン後も引き継ぐことができる(新規登録時)' do
      visit product_path(product)
      click_on 'カートに追加'
      expect(Cart.last.cart_items).to be_present

      visit new_user_registration_path

      fill_in 'user_name', with: 'Bob'
      fill_in 'user_email', with: 'bob@example.com'
      fill_in 'user_password', with: 'Abcd1234'
      fill_in 'user_password_confirmation', with: 'Abcd1234'

      within '.form-actions' do
        click_button '新規登録'
      end

      email = open_last_email
      click_first_link_in_email(email)

      fill_in 'user_email', with: 'bob@example.com'
      fill_in 'user_password', with: 'Abcd1234'

      within '.form-actions' do
        click_button 'ログイン'
      end

      click_on 'カート'
      expect(page).to have_css 'h1', text: 'カート'
      expect(page).to have_content 'ピーマン'
      expect(page).to have_content '1,000円'
    end


    it 'ログイン時にカートに追加済みの商品と同じ商品は引き継がれない', :js do
      user_login(user)
      click_on 'ピーマン'
      click_on 'カートに追加'

      expect(page).to have_css 'h1', text: 'カート'
      expect(page).to have_content 'ピーマン'
      expect(page).to have_content '1,000円'

      click_on 'ログアウト'
      expect(page.accept_confirm).to eq 'ログアウトしますか？'

      click_on 'ピーマン'
      click_on 'カートに追加'

      expect(page).to have_css 'h1', text: 'カート'
      expect(page).to have_content 'ピーマン'
      expect(page).to have_content '1,000円'

      user_login(user)
      visit cart_path
      expect{
        expect(page).to have_css 'h1', text: 'カート'
        expect(page).to have_content 'ピーマン'
        expect(page).to have_content '1,000円'
      }.to change(CartItem, :count).by(0)
    end
  end
end
