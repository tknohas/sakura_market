RSpec.describe 'Vendors', type: :system do
  let(:admin) { create(:admin) }
  let!(:vendor) { create(:vendor, name: 'アリスファーム', email: 'alicefarm@example.com', password: 'Abcd1234', created_at: '2024-09-28') }

  before do
    admin_login(admin)
    expect(page).to have_content 'ログインしました。'
  end

  describe '業者アカウント一覧' do
    it '業者情報が表示される' do
      click_on '業者一覧'

      expect(page).to have_css 'h1', text: '業者一覧'
      expect(page).to have_content 'アリスファーム'
      expect(page).to have_content 'alicefarm@example.com'
      expect(page).to have_content '2024年09月28日'
    end

    it '商品一覧画面へ遷移する' do
      visit admin_vendors_path
      click_on '商品一覧'
      expect(page).to have_css 'h1', text: '商品一覧(管理画面)'
    end

    it '編集画面へ遷移する' do
      visit admin_vendors_path
      click_on '編集'
      expect(page).to have_css 'h1', text: '業者アカウント編集'
    end

    it '業者を削除できる', :js do
      visit admin_vendors_path

      expect{
        click_on '削除'
        expect(page.accept_confirm).to eq '本当に削除しますか？'
        expect(page).to have_content '削除に成功しました。'
      }.to change(Vendor, :count).by(-1)
    end
  end

  describe '業者アカウント追加' do
    context 'フォームの入力値が正常' do
      it '業者を登録できる' do
        click_on '業者アカウント追加'

        fill_in 'vendor_email', with: 'bobfarm@example.com'
        fill_in 'vendor_name', with: 'ボブ農園'
        fill_in 'vendor_password', with: 'Abcd1234'
        fill_in 'vendor_password_confirmation', with: 'Abcd1234'
        within '.form-actions' do
          click_button '業者を追加'
        end

        expect(page).to have_content '業者が正常に追加されました。'
        expect(page).to have_css 'h1', text: '業者一覧'
      end
    end

    context 'フォームの入力値が異常' do
      it 'エラーメッセージが表示される' do
        click_on '業者アカウント追加'

        fill_in 'vendor_email', with: ''
        fill_in 'vendor_name', with: ''
        fill_in 'vendor_password', with: ''
        fill_in 'vendor_password_confirmation', with: ''
        within '.form-actions' do
          click_button '業者を追加'
        end

        expect(page).to have_css 'h1', text: '業者アカウント追加'
        expect(page).to have_content 'メールアドレスを入力してください'
        expect(page).to have_content 'パスワードを入力してください'
        expect(page).to have_content '業者名を入力してください'
      end
    end

    it '業者一覧画面へ遷移する' do
      visit new_vendor_registration_path
      click_on '業者一覧'
      expect(page).to have_css 'h1', text: '業者一覧'
    end
  end

  describe '業者アカウント編集' do
    context 'フォームの入力値が正常' do
      it '業者を編集できる' do
        visit edit_admin_vendor_path(vendor)

        fill_in 'vendor_email', with: 'bobfarm@example.com'
        fill_in 'vendor_name', with: 'ボブ農園'
        within '.form-actions' do
          click_button '変更'
        end

        expect(page).to have_content '変更しました。'
        expect(page).to have_css 'h1', text: '業者一覧'
      end
    end

    context 'フォームの入力値が異常' do
      it 'エラーメッセージが表示される' do
        visit edit_admin_vendor_path(vendor)

        fill_in 'vendor_email', with: ''
        fill_in 'vendor_name', with: ''
        within '.form-actions' do
          click_button '変更'
        end

        expect(page).to have_css 'h1', text: '業者アカウント編集'
        expect(page).to have_content 'メールアドレスを入力してください'
        expect(page).to have_content '業者名を入力してください'
      end

      it '業者一覧画面へ遷移する' do
        visit edit_admin_vendor_path(vendor)
        click_on '業者一覧'
        expect(page).to have_css 'h1', text: '業者一覧'
      end
    end
  end
end
