RSpec.describe 'Points', type: :system do
  let(:user) { create(:user) }
  let!(:coupon) { create(:coupon, code: 'Abcd-1234-febw', point: 1000) }
  let!(:coupon_usage) { create(:coupon_usage, coupon: coupon, user:, created_at: '2024-09-27') }

  before do
    user_login(user)
  end

  describe 'ポイント履歴' do
    it 'ポイント残高が表示される' do
      visit points_path
      expect(page).to have_content 'ポイント残高: 1000'
    end

    it '取得ポイントが表示される' do
      visit points_path

      expect(page).to have_css 'h1', text: 'ポイント履歴'
      texts = all('.earn-point table').map(&:text)
      expect(texts).to eq ['取得ポイント 取得日 1000 ポイント 2024年09月27日']
    end

    context '購入時にポイント使用した場合' do
      let!(:product) { create(:product, name: 'ピーマン', price: 1_000, description: '苦味が少ないです。') }
      let!(:purchase) { create(:purchase, user:, used_point: 800, created_at: '2024-09-27') }
      let!(:purchase_item) { create(:purchase_item, purchase:, product:) }

      it '使用ポイントが表示される' do
        visit points_path

        expect(page).to have_css 'h1', text: 'ポイント履歴'
        texts = all('.used-point table').map(&:text)
        expect(texts).to eq ['購入商品 使用ポイント 使用日 ピーマン 800 ポイント 2024年09月27日']
        expect(page).to have_content 'ポイント残高: 200'
      end
    end
  end
end
