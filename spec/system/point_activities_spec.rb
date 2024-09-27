RSpec.describe 'PointActivities', type: :system do
  let(:user) { create(:user) }
  let!(:coupon) { create(:coupon, code: 'Abcd-1234-febw', point: 1000) }
  let!(:coupon_usage) { create(:coupon_usage, coupon: coupon, user:, created_at: '2024-09-27') }

  before do
    user_login(user)
  end

  describe 'ポイント履歴' do
    it 'ポイント残高が表示される' do
      visit point_activities_path
      expect(page).to have_content 'ポイント残高: 1000'
    end

    context '購入時にポイント使用した場合' do
      let!(:product) { create(:product, name: 'ピーマン', price: 1_000, description: '苦味が少ないです。') }
      let!(:purchase) { create(:purchase, user:, used_point: 800, created_at: '2024-09-27') }
      let!(:purchase_item) { create(:purchase_item, purchase:, product:) }

      it 'ポイントの増減が表示される' do
        visit point_activities_path

        expect(page).to have_css 'h1', text: 'ポイント履歴'
        thead = all('div table thead').map(&:text)
        expect(thead).to eq ['取引内容 ポイント 有効期限 取得日']
        tr = all('div tbody tr').map(&:text)
        expect(tr[0]).to eq "購入時のポイント使用 -800 ポイント #{Date.current.strftime('%Y年%m月%d日')}"
        expect(tr[1]).to eq  "クーポンによるポイント獲得 1000 ポイント #{Date.current.strftime('%Y年%m月%d日')}"
      end

      it 'ポイント残高が表示される' do
        visit point_activities_path
        expect(page).to have_content 'ポイント残高: 200'
      end
    end
  end

  describe '有効期限' do
    context 'コードが数字のみの場合' do
      let!(:one_month_coupon) { create(:coupon, code: '1264-3423-3719', point: 100) }
      let!(:coupon_usage) { create(:coupon_usage, coupon: one_month_coupon, user:, created_at: '2024-09-27') }

      it '有効期限1ヶ月のポイントが付与される' do
        visit point_activities_path

        expect(page).to have_css 'h1', text: 'ポイント履歴'
        thead = all('div table thead').map(&:text)
        expect(thead).to eq ['取引内容 ポイント 有効期限 取得日']
        tr = all('div tbody tr').map(&:text)
        expect(tr).to eq ["クーポンによるポイント獲得 100 ポイント #{Date.current.next_month.strftime('%Y年%m月%d日')} #{Date.current.strftime('%Y年%m月%d日')}"]
      end
    end

    context 'コードが小文字の英字のみの場合' do
      let!(:one_week_coupon) { create(:coupon, code: 'rbns-jgnd-wmcs', point: 200) }
      let!(:coupon_usage) { create(:coupon_usage, coupon: one_week_coupon, user:, created_at: '2024-09-27') }

      it '有効期限1週間のポイントが付与される' do
        visit point_activities_path

        expect(page).to have_css 'h1', text: 'ポイント履歴'
        thead = all('div table thead').map(&:text)
        expect(thead).to eq ['取引内容 ポイント 有効期限 取得日']
        tr = all('div tbody tr').map(&:text)
        expect(tr).to eq ["クーポンによるポイント獲得 200 ポイント #{Date.current.since(7.days).strftime('%Y年%m月%d日')} #{Date.current.strftime('%Y年%m月%d日')}"]
      end
    end

    context 'コードが大文字の英字のみの場合' do
      let!(:end_of_month_coupon) { create(:coupon, code: 'ANKN-QOSS-VOLI', point: 300) }
      let!(:coupon_usage) { create(:coupon_usage, coupon: end_of_month_coupon, user:, created_at: '2024-09-27') }

      it '有効期限1週間のポイントが付与される' do
        visit point_activities_path

        expect(page).to have_css 'h1', text: 'ポイント履歴'
        thead = all('div table thead').map(&:text)
        expect(thead).to eq ['取引内容 ポイント 有効期限 取得日']
        tr = all('div tbody tr').map(&:text)
        expect(tr).to eq ["クーポンによるポイント獲得 300 ポイント #{Date.current.end_of_month.strftime('%Y年%m月%d日')} #{Date.current.strftime('%Y年%m月%d日')}"]
      end
    end
  end
end
