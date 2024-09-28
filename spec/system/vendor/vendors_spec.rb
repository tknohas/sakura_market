RSpec.describe 'Vendors', type: :system do
  let!(:vendor) { create(:vendor, name: 'アリスファーム', email: 'alicefarm@example.com', password: 'Abcd1234', created_at: '2024-09-28') }

  describe 'ログイン' do
    before do
      visit new_vendor_session_path
    end

    context 'フォームの入力値が正常' do
      it 'ログイン成功' do
        fill_in 'vendor_email', with: 'alicefarm@example.com'
        fill_in 'vendor_password', with: 'Abcd1234'

        within '.form-actions' do
          click_button 'ログイン'
        end

        expect(page).to have_content 'ログインしました'
        expect(current_path).to eq edit_vendor_registration_path
      end
    end

    context 'フォームの入力値が異常' do
      it 'ログイン失敗(パスワード不正)' do
        fill_in 'vendor_email', with: 'alicefarm@example.com'
        fill_in 'vendor_password', with: 'Aaaa1234'

        within '.form-actions' do
          click_button 'ログイン'
        end

        expect(page).to have_css 'h1', text: 'ログイン'
        expect(page).to have_content 'メールアドレスまたはパスワードが違います。'
      end

      it 'ログイン失敗(メールアドレス不正)' do
        fill_in 'vendor_email', with: 'aaa@example.com'
        fill_in 'vendor_password', with: 'Abcd1234'

        within '.form-actions' do
          click_button 'ログイン'
        end

        expect(page).to have_css 'h1', text: 'ログイン'
        expect(page).to have_content 'メールアドレスまたはパスワードが違います。'
      end
    end

    context '初回ログイン時または初期パスワードを変更していない場合' do
      it 'ログイン後にパスワード変更を求められる' do
        fill_in 'vendor_email', with: 'alicefarm@example.com'
        fill_in 'vendor_password', with: 'Abcd1234'

        within '.form-actions' do
          click_button 'ログイン'
        end

        expect(page).to have_css 'h1', text: 'パスワード変更'
        expect(page).to have_content 'パスワードの変更を推奨しています。'

        fill_in 'vendor_current_password', with: 'Abcd1234'
        fill_in 'vendor_password', with: 'aAAA1234'
        fill_in 'vendor_password_confirmation', with: 'aAAA1234'

        click_on 'パスワードを変更する'

        expect(page).to have_css 'h1', text: '商品一覧'
        expect(page).to have_content 'アカウント情報を変更しました。'
      end
    end

    context '初期パスワードを変更済みの場合' do
      let!(:password_changed_vendor) { create(:vendor, name: 'ボブ農園', email: 'bobnouen@example.com', password: 'Abcd1234', password_changed: true) }

      it 'ログイン後に商品一覧画面へ遷移する' do
        fill_in 'vendor_email', with: 'bobnouen@example.com'
        fill_in 'vendor_password', with: 'Abcd1234'

        within '.form-actions' do
          click_button 'ログイン'
        end

        expect(page).to have_content 'ログインしました。'
        expect(page).to have_css 'h1', text: '商品一覧'
        expect(page).to have_current_path vendor_products_path
      end
    end
  end
end
