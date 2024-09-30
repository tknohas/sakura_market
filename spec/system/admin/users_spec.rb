RSpec.describe 'Users', type: :system do
  let(:admin) { create(:admin) }

  before do
    admin_login(admin)
    expect(page).to have_content 'ログインしました。'
  end

  describe '顧客一覧' do
    context 'ユーザーが退会していない場合' do
      let!(:user) { create(:user, name: 'Alice', email: 'alice@example.com', created_at: '2024-09-23') }

      it '顧客情報が表示される' do
        visit admin_users_path

        expect(page).to have_css 'h1', text: '顧客一覧'
        texts = all('tbody tr td').map(&:text)
        expect(texts).to eq ["#{User.last.id}", 'Alice 様', 'alice@example.com', '2024年09月23日']
      end

      it '顧客詳細画面へ遷移する' do
        visit admin_users_path
        click_on 'Alice 様'
        expect(page).to have_css 'h1', text: '顧客詳細'
      end
    end

    context 'ユーザーが退会している場合' do
      let!(:canceled_user) { create(:user, name: 'Bob', email: 'bob@example.com', created_at: '2024-09-22', canceled_at: '2024-09-23') }

      it '顧客情報に加え、退会日と削除ボタンが表示される' do
        visit admin_users_path

        expect(page).to have_css 'h1', text: '顧客一覧'
        texts = all('tbody tr td').map(&:text)
        expect(texts).to eq ["#{User.last.id}", 'Bob 様', 'bob@example.com', '2024年09月22日', '2024年09月23日', '削除']
      end

      it '論理削除できる', :js do
        visit admin_users_path

        click_on '削除'
        expect(page.accept_confirm).to eq '本当に削除しますか？'
        expect(page).to have_content '削除に成功しました。'
        expect(page).to have_css 'h1', text: '顧客一覧'
        texts = all('tbody tr td').map(&:text)
        expect(texts).to eq []
        expect(User.last).to_not be_present
        expect(User.with_discarded.discarded).to be_present

        user_login(canceled_user)
        expect(page).to have_content 'メールアドレスまたはパスワードが違います。'
      end

      it '顧客詳細画面へ遷移する' do
        visit admin_users_path
        click_on 'Bob 様'
        expect(page).to have_css 'h1', text: '顧客詳細'
      end
    end
  end

  describe '顧客詳細' do
    let!(:user) { create(:user, name: 'Alice', email: 'alice@example.com', created_at: '2024-09-23') }
    let!(:address) { create(:address, postal_code: '100-0005', prefecture: '東京都', city: '千代田区', street: '丸の内1丁目', user:) }

    it '基本情報が表示される' do
      visit admin_user_path(user)

      expect(page).to have_css 'h1', text: '顧客詳細'
      expect(page).to have_content 'Alice 様'
      expect(page).to have_content 'alice@example.com'
    end

    it '住所情報が表示される' do
      visit admin_user_path(user)

      expect(page).to have_css 'h1', text: '顧客詳細'
      expect(page).to have_content '〒100-0005'
      expect(page).to have_content '東京都 千代田区 丸の内1丁目'
    end

    context 'ユーザーが退会していない場合' do
      it 'アカウントを有効化・無効化できる' do
        visit admin_user_path(user)
        click_on 'アカウントを無効化'

        expect(page).to have_content 'アカウントを無効化しました。'
        user_login(user)
        expect(page).to have_content 'このアカウントは利用できません。'

        visit admin_user_path(user)
        click_on 'アカウントを有効化'

        expect(page).to have_content 'アカウントを有効化しました。'
        user_login(user)
        expect(page).to have_content 'ログインしました。'
      end
    end

    context 'ユーザーが退会している場合' do
      let!(:canceled_user) { create(:user, name: 'Bob', email: 'bob@example.com', created_at: '2024-09-22', canceled_at: '2024-09-23') }

      it 'アカウントを有効化・無効化ボタンが表示されない' do
        visit admin_user_path(canceled_user)

        expect(page).to have_css 'h1', text: '顧客詳細'
        expect(page).to_not have_content 'アカウントを無効化'
        expect(page).to_not have_content 'アカウントを有効化'
      end
    end
  end
end
