RSpec.describe 'Products', type: :system do
  let!(:product) { create(:product, name: 'ピーマン', price: 1_000, description: '苦味が少ないです。', sort_position: 1, created_at: '2024-01-01') }
  let(:vendor) { create(:vendor, name: 'アリスファーム') }
  let!(:stock) { create(:stock, product:, vendor:, quantity: 9) }

  describe '一覧画面' do
    let(:admin) { create(:admin) }
    let!(:highest_price_product) { create(:product, name: 'にんじん', price: 10_000, sort_position: 3, created_at: '2024-04-01') }
    let!(:lowest_price_product) { create(:product, name: '玉ねぎ', price: 100, sort_position: 2, created_at: '2024-07-01') }

    it '商品情報が表示される' do
      visit products_path

      expect(page).to have_css 'h1', text: '商品一覧'
      expect(page).to have_css 'img.product-image'
      expect(page).to have_content 'ピーマン'
    end

    it '価格が安い順に並び替わる', js: true do
      admin_login(admin)
      select '価格が安い順', from: 'sort_order'
      visit products_path

      expect(page).to have_css 'h1', text: '商品一覧'
      products = all('div a p').map(&:text)
      expect(products).to eq ['玉ねぎ', 'ピーマン', 'にんじん']
    end

    it '価格が高い順に並び替わる', js: true do
      admin_login(admin)
      select '価格が高い順', from: 'sort_order'
      visit products_path

      expect(page).to have_css 'h1', text: '商品一覧'
      products = all('div a p').map(&:text)
      expect(products).to eq ['にんじん', 'ピーマン', '玉ねぎ']
    end

    it '表示順に並び替わる', js: true do
      admin_login(admin)
      select '表示順', from: 'sort_order'
      visit products_path

      expect(page).to have_css 'h1', text: '商品一覧'
      products = all('div a p').map(&:text)
      expect(products).to eq ['ピーマン', '玉ねぎ', 'にんじん']
    end

    it '新着順に並び替わる', js: true do
      admin_login(admin)
      select '新着順', from: 'sort_order'
      visit products_path

      expect(page).to have_css 'h1', text: '商品一覧'
      products = all('div a p').map(&:text)
      expect(products).to eq ['玉ねぎ', 'にんじん', 'ピーマン']
    end

    it '商品詳細画面へ遷移する' do
      visit products_path
      click_on 'ピーマン'

      expect(page).to have_css 'h1', text: '商品詳細'
    end
  end

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
      visit products_path
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
        find('#cart_item_vendor_id').select('アリスファーム')
        click_on 'カートに追加'

        expect(page).to have_css 'h1', text: 'カート'
        expect(page).to have_css 'img.product-image'
        expect(page).to have_content 'ピーマン'
        expect(page).to have_content 'アリスファーム'
        expect(page).to have_content '1,000円'
        expect(page).to have_content '1'
        expect(CartItem.last.quantity).to eq 1
      end
    end

    context 'カートにすでに同じ商品がある場合' do
      let!(:cart) { create(:cart, user:) }
      let!(:cart_item) { create(:cart_item, cart:, product:, vendor:) }

      context 'カートの商品の業者と同じ場合' do
        it 'カートに商品を追加できる' do
          visit product_path(product)
          find('#cart_item_vendor_id').select('アリスファーム')
          click_on 'カートに追加'

          expect(page).to have_content '商品がカートに追加されました。'
          expect(page).to have_css 'h1', text: 'カート'
          expect(page).to have_css 'img.product-image'
          expect(page).to have_content 'ピーマン'
          expect(page).to have_content 'アリスファーム'
          expect(page).to have_content '1,000円'
          expect(page).to have_content '2'
          expect(page).to have_content '2,000円'
          expect(CartItem.last.quantity).to eq 2
        end
      end

      context 'カートの商品の業者と異なる場合' do
        let(:unselectable_vendor) { create(:vendor, name: 'ボブ食堂') }
        let!(:unselectable_vendor_stock) { create(:stock, product:, vendor: unselectable_vendor) }

        it 'カートに商品を追加できない' do
          visit product_path(product)
          find('#cart_item_vendor_id').select('ボブ食堂')
          click_on 'カートに追加'

          expect(page).to have_content '同じ販売元の商品のみカートに追加できます。'
          expect(page).to have_css 'h1', text: '商品詳細'
        end
      end
    end

    it 'カートの商品を削除できる', :js do
      visit product_path(product)
      find('#cart_item_vendor_id').select('アリスファーム')
      click_on 'カートに追加'
      expect(page).to have_css 'h1', text: 'カート'

      expect {
        click_on '削除'
        expect(page.accept_confirm).to eq '本当に削除しますか？'
        expect(page).to have_content '商品を削除しました。'
      }.to change(CartItem, :count).by(-1)
    end

    it '商品一覧画面へ遷移する' do
      visit cart_path
      click_on '買い物を続ける'

      expect(page).to have_css 'h1', text: '商品一覧'
      expect(page).to have_current_path products_path
    end

    it '商品の在庫が追加する商品数より少なければエラーメッセージが表示される' do
      visit product_path(product)
      find('#cart_item_quantity').select(10)
      find('#cart_item_vendor_id').select('アリスファーム')
      click_on 'カートに追加'

      expect(page).to have_content '在庫数を超える商品数を追加できません。'
      expect(page).to have_css 'h1', text: '商品詳細'
    end
  end

  describe 'カート(セッション)' do
    let(:user) { create(:user, name: 'alice@example.com', password: 'Abcd1234') }

    context 'カートに同じ商品がない場合' do
      it 'カートに商品を追加できる' do
        visit product_path(product)
        find('#cart_item_vendor_id').select('アリスファーム')
        click_on 'カートに追加'

        expect(page).to have_css 'h1', text: 'カート'
        expect(page).to have_css 'img.product-image'
        expect(page).to have_content 'ピーマン'
        expect(page).to have_content '1,000円'
      end
    end

    context 'カートにすでに同じ商品がある場合' do
      context 'カートの商品の業者と同じ場合' do
        it 'カートに商品を追加できる' do
          visit product_path(product)
          find('#cart_item_vendor_id').select('アリスファーム')
          click_on 'カートに追加'

          visit product_path(product)
          find('#cart_item_vendor_id').select('アリスファーム')
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

      context 'カートの商品の業者と異なる場合' do
        let(:unselectable_vendor) { create(:vendor, name: 'ボブ食堂') }
        let!(:unselectable_vendor_stock) { create(:stock, product:, vendor: unselectable_vendor) }

        it 'カートに商品を追加できない' do
          visit product_path(product)
          find('#cart_item_vendor_id').select('アリスファーム')
          click_on 'カートに追加'

          visit product_path(product)
          find('#cart_item_vendor_id').select('ボブ食堂')
          click_on 'カートに追加'

          expect(page).to have_content '同じ販売元の商品のみカートに追加できます。'
          expect(page).to have_css 'h1', text: '商品詳細'
        end
      end
    end

    it 'カートの商品を削除できる', :js do
      visit product_path(product)
      find('#cart_item_vendor_id').select('アリスファーム')
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
      find('#cart_item_vendor_id').select('アリスファーム')
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
      find('#cart_item_vendor_id').select('アリスファーム')
      click_on 'カートに追加'
      expect(Cart.last.cart_items).to be_present

      visit new_user_registration_path

      fill_in 'user_name', with: 'Bob'
      fill_in 'user_nickname', with: 'bb'
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

    context 'ログイン時にカートに商品を追加済みの場合', :js do
      before do
        user_login(user)
        click_on '商品一覧'
        click_on 'ピーマン'
        find('#cart_item_vendor_id').select('アリスファーム')
        click_on 'カートに追加'

        expect(page).to have_css 'h1', text: 'カート'
        expect(page).to have_content 'ピーマン'
        expect(page).to have_content 1
        expect(page).to have_content '1,000円'

        click_on 'ログアウト'
        expect(page.accept_confirm).to eq 'ログアウトしますか？'
      end

      context 'カートの商品の業者と同じ場合' do
        it '数量が追加される' do
          click_on '商品一覧'
          click_on 'ピーマン'
          find('#cart_item_vendor_id').select('アリスファーム')
          click_on 'カートに追加'

          expect(page).to have_css 'h1', text: 'カート'
          expect(page).to have_content 'ピーマン'
          expect(page).to have_content 1
          expect(page).to have_content '1,000円'

          user_login(user)
          click_on 'カート'

          expect(page).to have_css 'h1', text: 'カート'
          expect(page).to have_content 'ピーマン'
          expect(page).to have_content 2
          expect(page).to have_content '2,000円'
        end
      end

      context 'カートの商品の業者と異なる場合' do
        let(:unselectable_vendor) { create(:vendor, name: 'ボブ食堂') }
        let!(:unselectable_vendor_stock) { create(:stock, product:, vendor: unselectable_vendor) }

        it '商品は引き継がれない' do
          click_on '商品一覧'
          click_on 'ピーマン'
          find('#cart_item_vendor_id').select('ボブ食堂')
          click_on 'カートに追加'

          expect(page).to have_css 'h1', text: 'カート'
          expect(page).to have_content 'ピーマン'
          expect(page).to have_content 1
          expect(page).to have_content '1,000円'

          user_login(user)
          click_on 'カート'

          expect(page).to have_css 'h1', text: 'カート'
          expect(page).to have_content 'ピーマン'
          expect(page).to have_content 1
          expect(page).to have_content '1,000円'
        end
      end
    end
  end
end
