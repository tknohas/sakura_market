RSpec.describe 'Admins', type: :system do
  let(:admin) { create(:admin) }

  describe 'ログイン' do
    before do
      visit new_admin_session_path
    end

    context 'フォームの入力値が正常' do
      it 'ログイン成功' do
        fill_in 'admin_email', with: admin.email
        fill_in 'admin_password', with: 'Abcd1234'
        within '.form-actions' do
          click_button 'ログイン'
        end

        expect(page).to have_content 'ログインしました'
        expect(current_path).to eq admin_products_path
      end
    end

    context 'フォームの入力値が異常' do
      it 'ログイン失敗(パスワード不正)' do
        fill_in 'admin_email', with: 'admin@example.com'
        fill_in 'admin_password', with: 'aaa'
        within '.form-actions' do
          click_button 'ログイン'
        end

        expect(page).to have_css 'h1', text: 'ログイン'
        expect(page).to have_content 'Eメールまたはパスワードが違います。'
      end

      it 'ログイン失敗(メールアドレス不正)' do
        fill_in 'admin_email', with: 'aaa@example.com'
        fill_in 'admin_password', with: 'Abcd1234'
        within '.form-actions' do
          click_button 'ログイン'
        end

        expect(page).to have_css 'h1', text: 'ログイン'
        expect(page).to have_content 'Eメールまたはパスワードが違います。'
      end
    end
  end

  it 'ログイン前はadmin_root_pathに遷移できない' do
    visit admin_products_path
    
    expect(page).to have_css 'h1', text: 'ログイン'
    expect(page).to have_content 'ログインもしくはアカウント登録してください。'
  end
end
