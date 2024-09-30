RSpec.describe 'Coupons', type: :system do
  let!(:admin) { create(:admin) }
  let!(:coupon) { create(:coupon, code: 'Abcd-1234-febw', point: 100) }

  before do
    admin_login(admin)
    expect(page).to have_content 'ログインしました。'
  end

  describe '一覧画面' do
    it 'クーポンの情報が表示される' do
      click_on 'クーポン一覧'

      expect(page).to have_css 'h1', text: 'クーポン一覧'
      expect(page).to have_content 'Abcd-1234-febw'
      expect(page).to have_content 100
    end

    it 'クーポン登録画面へ遷移する' do
      click_on 'クーポン一覧'
      click_on 'クーポン登録'

      expect(page).to have_css 'h1', text: 'クーポン登録'
    end

    it 'クーポン編集画面へ遷移する' do
      click_on 'クーポン一覧'
      click_on '編集'

      expect(page).to have_css 'h1', text: 'クーポン編集'
    end

    it 'クーポンを削除できる', :js do
      click_on 'クーポン一覧'

      expect{
        click_on '削除'
        expect(page.accept_confirm).to eq '本当に削除しますか？'
        expect(page).to have_content 'クーポンを削除しました。'
      }.to change(Coupon, :count).by(-1)
    end
  end

  describe 'クーポン登録' do
    context 'フォームの入力値が正常な場合' do
      it 'クーポンを登録できる' do
        visit new_admin_coupon_path

        fill_in 'coupon_code', with: '31vq-ago2-Ned2'
        fill_in 'coupon_point', with: 200
        fill_in 'coupon_expires_at', with: Date.current
        click_on '登録'

        expect(page).to have_content 'クーポンを作成しました。'
        expect(page).to have_css 'h1', text: 'クーポン一覧'
        expect(page).to have_content '31vq-ago2-Ned2'
        expect(page).to have_content 200
        expect(page).to have_content Date.current.strftime('%Y年%m月%d日')
      end
    end

    context 'フォームの入力値が異常な場合' do
      it 'エラーメッセージが表示される' do
        visit new_admin_coupon_path

        fill_in 'coupon_code', with: ''
        fill_in 'coupon_point', with: ''
        click_on '登録'

        expect(page).to have_css 'h1', text: 'クーポン登録'
        expect(page).to have_content 'クーポンコードは不正な値です'
        expect(page).to have_content 'ポイントは数値で入力してください'
        expect(page).to have_content 'クーポンコードを入力してください'
        expect(page).to have_content 'ポイントを入力してください'
      end
    end

    it '戻るボタンでクーポン一覧画面に戻る' do
      visit admin_coupons_path

      expect(page).to have_css 'h1', text: 'クーポン一覧'
      click_on 'クーポン登録'
      click_on '戻る'

      expect(page).to have_css 'h1', text: 'クーポン一覧'
    end
  end

  describe 'クーポン編集' do
    context 'フォームの入力値が正常な場合' do
      it 'クーポンを編集できる' do
        visit edit_admin_coupon_path(coupon)

        fill_in 'coupon_code', with: '31vq-ago2-Ned2'
        fill_in 'coupon_point', with: 200
        fill_in 'coupon_expires_at', with: Date.current
        click_on '変更'

        expect(page).to have_content 'クーポンを更新しました。'
        expect(page).to have_css 'h1', text: 'クーポン一覧'
        expect(page).to have_content '31vq-ago2-Ned2'
        expect(page).to have_content 200
        expect(page).to have_content Date.current.strftime('%Y年%m月%d日')
      end
    end

    context 'フォームの入力値が異常な場合' do
      it 'エラーメッセージが表示される' do
        visit edit_admin_coupon_path(coupon)

        fill_in 'coupon_code', with: ''
        fill_in 'coupon_point', with: ''
        click_on '変更'

        expect(page).to have_css 'h1', text: 'クーポン編集'
        expect(page).to have_content 'クーポンコードは不正な値です'
        expect(page).to have_content 'ポイントは数値で入力してください'
        expect(page).to have_content 'クーポンコードを入力してください'
        expect(page).to have_content 'ポイントを入力してください'
      end
    end

    it '前の画面へ戻る' do
      visit admin_coupons_path

      click_on '編集'
      click_on '戻る'

      expect(page).to have_css 'h1', text: 'クーポン一覧'
    end
  end

  describe '利用状況' do
    let!(:user) { create(:user, name: 'Alice') }
    let!(:coupon_usage) { create(:coupon_usage, user:, coupon:, created_at: '2024-09-27') }

    it 'クーポンの使用者と使用日が表示される' do
      visit admin_coupon_path(coupon)

      expect(page).to have_css 'h1', text: '利用状況'
      expect(page).to have_content 'Alice 様'
      expect(page).to have_content '2024年09月27日'
    end

    it '前の画面へ戻る' do
      visit admin_coupons_path

      click_on 'Abcd-1234-febw'
      click_on '戻る'

      expect(page).to have_css 'h1', text: 'クーポン一覧'
    end
  end
end
