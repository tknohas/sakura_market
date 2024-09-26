RSpec.describe 'Coupons', type: :system do
  let(:user) { create(:user) }
  let!(:added_coupon) { create(:coupon, code: 'Abcd-1234-febw', point: 100) }
  let!(:coupon) { create(:coupon, code: '31vq-ago2-Ned2', point: 200, expires_at: Date.current) }
  let!(:coupon_usage) { create(:coupon_usage, coupon: added_coupon, user:) }

  before do
    user_login(user)
  end

  describe '一覧画面' do
    it 'クーポンの情報が表示される' do
      visit coupons_path

      expect(page).to have_css 'h1', text: '登録クーポン一覧'
      expect(page).to have_content 'Abcd-1234-febw'
      expect(page).to have_content 100
    end
  end

  describe 'クーポン適用' do
    context 'フォームの入力値が正常な場合' do
      it 'クーポンを適用できる' do
        visit products_path

        fill_in 'code', with: '31vq-ago2-Ned2'

        click_on '適用'

        expect(page).to have_content 'クーポンを適用しました。'
        expect(page).to have_css 'h1', text: '登録クーポン一覧'
        expect(page).to have_content '31vq-ago2-Ned2'
        expect(page).to have_content 200
        expect(page).to have_content Date.current.strftime('%Y年%m月%d日')
      end
    end

    context 'フォームの入力値がすでに適用されているコードの場合' do
      it 'エラーメッセージが表示される' do
        visit products_path

        fill_in 'code', with: 'Abcd-1234-febw'

        click_on '適用'

        expect(page).to have_css 'h1', text: '商品一覧'
        expect(page).to have_content '無効なクーポンコードです。'
      end
    end
  end
end
