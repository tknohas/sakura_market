RSpec.describe 'Products', type: :system do
  let(:user) { create(:user) }
  let!(:product) { create(:product) }
  let(:vendor) { create(:vendor, name: 'アリスファーム') }

  describe '住所登録' do
    let!(:cart) { create(:cart, user:) }
    let!(:cart_item) { create(:cart_item, cart:, product:, vendor:) }

    before do
      user_login(user)
    end

    context 'フォームの入力値が正常な場合' do
      it '住所を登録できる' do
        visit new_address_path

        fill_in 'address_postal_code', with: '279-0031'
        fill_in 'address_prefecture', with: '千葉県'
        fill_in 'address_city', with: '浦安市'
        fill_in 'address_street', with: '舞浜1-1'

        click_on '登録'

        expect(page).to have_content '住所が登録されました。'
        expect(page).to have_css 'h1', text: 'カート'
        expect(page).to have_content '279-0031'
        expect(page).to have_content '千葉県'
        expect(page).to have_content '浦安市'
        expect(page).to have_content '舞浜1-1'
      end
    end

    context 'フォームの入力値が異常な場合' do
      it 'エラーメッセージが表示される' do
        visit new_address_path

        fill_in 'address_postal_code', with: ''
        fill_in 'address_prefecture', with: ''
        fill_in 'address_city', with: ''
        fill_in 'address_street', with: ''

        click_on '登録'

        expect(page).to have_content '住所登録'
        expect(page).to have_content '郵便番号を入力してください'
        expect(page).to have_content '都道府県を入力してください'
        expect(page).to have_content '市区町村を入力してください'
        expect(page).to have_content 'それ以降の住所を入力してください'
      end
    end
  end

  describe '住所変更' do
    let!(:cart) { create(:cart, user:) }
    let!(:cart_item) { create(:cart_item, cart:, product:, vendor:) }
    let!(:address) { create(:address, postal_code: '100-0005', prefecture: '東京都', city: '千代田区', street: '丸の内1丁目', user:) }

    before do
      user_login(user)
    end

    context 'フォームの入力値が正常な場合' do
      it '住所を変更できる' do
        visit edit_address_path

        fill_in 'address_postal_code', with: '279-0031'
        fill_in 'address_prefecture', with: '千葉県'
        fill_in 'address_city', with: '浦安市'
        fill_in 'address_street', with: '舞浜1-1'

        click_on '変更'

        expect(page).to have_content '住所が変更されました。'
        expect(page).to have_css 'h1', text: '購入確認'
        expect(page).to have_content '279-0031'
        expect(page).to have_content '千葉県'
        expect(page).to have_content '浦安市'
        expect(page).to have_content '舞浜1-1'
      end
    end

    context 'フォームの入力値が異常な場合' do
      it 'エラーメッセージが表示される' do
        visit edit_address_path

        fill_in 'address_postal_code', with: ''
        fill_in 'address_prefecture', with: ''
        fill_in 'address_city', with: ''
        fill_in 'address_street', with: ''

        click_on '変更'

        expect(page).to have_content '住所変更'
        expect(page).to have_content '郵便番号を入力してください'
        expect(page).to have_content '都道府県を入力してください'
        expect(page).to have_content '市区町村を入力してください'
        expect(page).to have_content 'それ以降の住所を入力してください'
      end
    end
  end

  describe '住所表示' do
    it 'カートに商品が入っていない時は住所や登録用リンクが表示されない' do
      visit cart_path

      expect(page).to have_css 'h1', text: 'カート'
      expect(page).to_not have_content '100-0005'
      expect(page).to_not have_content '東京都'
      expect(page).to_not have_content '千代田区'
      expect(page).to_not have_content '丸の内1丁目'
      expect(page).to_not have_link 'こちらから住所を登録してください。', href: new_address_path
    end

    context 'ログインしている場合' do
      let!(:cart) { create(:cart, user:) }
      let!(:cart_item) { create(:cart_item, cart:, product:, vendor:) }

      before do
        user_login(user)
      end

      context '住所を登録している場合' do
        let!(:address) { create(:address, postal_code: '100-0005', prefecture: '東京都', city: '千代田区', street: '丸の内1丁目', user:) }

        it 'カートに住所が表示される' do
          visit cart_path

          expect(page).to have_css 'h1', text: 'カート'
          expect(page).to have_content '100-0005'
          expect(page).to have_content '東京都'
          expect(page).to have_content '千代田区'
          expect(page).to have_content '丸の内1丁目'
        end

        it '住所変更画面に遷移できる' do
          visit cart_path

          click_on '住所の変更はこちら'
          expect(page).to have_css 'h1', text: '住所変更'
        end
      end

      context '住所を登録していない場合' do
        it 'カートに住所登録用のURLが表示される' do
          visit cart_path

          expect(page).to have_css 'h1', text: 'カート'
          expect(page).to have_link 'こちらから住所を登録してください。', href: new_address_path
        end
      end
    end

    context 'ログインしていない場合' do
      let!(:address) { create(:address, postal_code: '100-0005', prefecture: '東京都', city: '千代田区', street: '丸の内1丁目', user:) }
      let!(:stock) { create(:stock, quantity: 1, product:, vendor:) }

      it 'カートに商品があり、住所が登録されていても住所や登録用リンクが表示されない' do
        visit product_path(product)
        find('#cart_item_vendor_id').select('アリスファーム')
        click_on 'カートに追加'

        expect(page).to have_css 'h1', text: 'カート'
        expect(page).to have_content 'ピーマン'
        expect(page).to have_content '1,000円'

        expect(page).to_not have_content '100-0005'
        expect(page).to_not have_content '東京都'
        expect(page).to_not have_content '千代田区'
        expect(page).to_not have_content '丸の内1丁目'
        expect(page).to_not have_link 'こちらから住所を登録してください。', href: new_address_path
      end
    end
  end
end
