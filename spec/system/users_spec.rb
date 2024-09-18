RSpec.describe 'Users', type: :system do
  let!(:user) { create(:user, name: 'Alice', email: 'alice@example.com', password: 'Abcd1234') }

  describe 'ログイン' do
    before do
      visit new_user_session_path
    end

    context 'フォームの入力値が正常' do
      it 'ログイン成功' do
        fill_in 'user_email', with: 'alice@example.com'
        fill_in 'user_password', with: 'Abcd1234'

        within '.form-actions' do
          click_button 'ログイン'
        end

        expect(page).to have_content 'ログインしました'
        expect(current_path).to eq root_path
      end
    end

    context 'フォームの入力値が異常' do
      it 'ログイン失敗(パスワード不正)' do
        fill_in 'user_email', with: 'alice@example.com'
        fill_in 'user_password', with: 'aaa'

        within '.form-actions' do
          click_button 'ログイン'
        end

        expect(page).to have_css 'h1', text: 'ログイン'
        expect(page).to have_content 'メールアドレスまたはパスワードが違います。'
      end

      it 'ログイン失敗(メールアドレス不正)' do
        fill_in 'user_email', with: 'aaa@example.com'
        fill_in 'user_password', with: 'Abcd1234'

        within '.form-actions' do
          click_button 'ログイン'
        end

        expect(page).to have_css 'h1', text: 'ログイン'
        expect(page).to have_content 'メールアドレスまたはパスワードが違います。'
      end
    end
  end

  describe '新規登録' do
    before do
      visit new_user_registration_path
    end

    context 'フォームの入力値が正常' do
      it '登録成功' do
        fill_in 'user_name', with: 'Bob'
        fill_in 'user_email', with: 'bob@example.com'
        fill_in 'user_password', with: 'Abcd1234'
        fill_in 'user_password_confirmation', with: 'Abcd1234'

        within '.form-actions' do
          click_button '新規登録'
        end

        expect(page).to have_content '本人確認用のメールを送信しました。メール内のリンクからアカウントを有効化させてください。'

        email = open_last_email
        expect(email).to have_subject 'メールアドレス確認メール'
        click_first_link_in_email(email)

        expect(page).to have_content 'メールアドレスが確認できました。'
        fill_in 'user_email', with: 'bob@example.com'
        fill_in 'user_password', with: 'Abcd1234'

        within '.form-actions' do
          click_button 'ログイン'
        end

        expect(page).to have_content 'ログインしました'
        expect(current_path).to eq root_path
      end
    end

    context 'フォームの入力値が異常' do
      it '登録失敗' do
        fill_in 'user_name', with: 'Bob'
        fill_in 'user_email', with: 'alice@example.com'
        fill_in 'user_password', with: 'Abcd1234'
        fill_in 'user_password_confirmation', with: 'Abcd1235'

        within '.form-actions' do
          click_button '新規登録'
        end

        expect(page).to have_content 'メールアドレスはすでに存在します'
        expect(page).to have_content 'パスワード（確認用）とパスワードの入力が一致しません'
        expect(page).to have_css 'h1', text: '新規登録'
      end

      it '登録失敗（パスワード不正）' do
        fill_in 'user_name', with: 'Bob'
        fill_in 'user_email', with: 'bob@example.com'
        fill_in 'user_password', with: '12345678'
        fill_in 'user_password_confirmation', with: '12345678'

        within '.form-actions' do
          click_button '新規登録'
        end

        expect(page).to have_content '8文字以上20文字以下で半角英数字の小文字、大文字、数字が含まれている必要があります。'
        expect(page).to have_css 'h1', text: '新規登録'
      end
    end
  end

  describe '確認メール再送信' do
    let!(:unconfirmed_user) { create(:user, name: 'Franky', email: 'franky@example.com', password: 'Abcd1234', confirmed_at: nil) }

    before do
      visit new_user_session_path
      click_on '確認メール再送信'
    end

    context '登録されていないメールアドレスの場合' do
      it '登録成功' do
        fill_in 'user_email', with: 'franky@example.com'

        click_button '確認メール再送信'

        expect(page).to have_content 'アカウントの有効化について数分以内にメールでご連絡します。'

        email = open_last_email
        expect(email).to have_subject 'メールアドレス確認メール'
        click_first_link_in_email(email)

        expect(page).to have_content 'メールアドレスが確認できました。'
        fill_in 'user_email', with: 'franky@example.com'
        fill_in 'user_password', with: 'Abcd1234'

        within '.form-actions' do
          click_button 'ログイン'
        end

        expect(page).to have_content 'ログインしました'
        expect(current_path).to eq root_path
      end
    end

    context '登録済みのメールアドレスの場合' do
      it 'メールが送信されない' do
        fill_in 'user_email', with: 'alice@example.com'

        click_button '確認メール再送信'

        expect(page).to have_content 'メールアドレスは既に登録済みです。ログインしてください。'
        expect(page).to have_css 'h1', text: '確認メール再送信'
      end
    end

    context '新規登録前の場合' do
      it 'メールが送信されない' do
        fill_in 'user_email', with: 'koby@example.com'

        click_button '確認メール再送信'

        expect(page).to have_content 'メールアドレスは見つかりませんでした。'
        expect(page).to have_css 'h1', text: '確認メール再送信'
      end
    end
  end

  describe 'パスワードリセット' do
    before do
      visit new_user_session_path
      click_on 'パスワードリセット'
    end

    context 'フォームの入力値が正常' do
      it '登録成功' do
        fill_in 'user_email', with: 'alice@example.com'

        click_button 'パスワードリセット'

        expect(page).to have_content 'パスワードの再設定について数分以内にメールでご連絡いたします。'

        email = open_last_email
        expect(email).to have_subject 'パスワードの再設定について'
        click_first_link_in_email(email)

        fill_in 'user_password', with: 'Abcd9876'
        fill_in 'user_password_confirmation', with: 'Abcd9876'

        click_button 'パスワード変更'

        expect(page).to have_content 'パスワードが正しく変更されました。'
        expect(current_path).to eq root_path
      end
    end

    context 'フォームの入力値が異常' do
      it 'メールが送信されない' do
        fill_in 'user_email', with: 'unknown_user@example.com'

        click_button 'パスワードリセット'

        expect(page).to have_content 'メールアドレスは見つかりませんでした。'
        expect(page).to have_css 'h1', text: 'パスワードをお忘れの方'
      end
    end
  end
end
