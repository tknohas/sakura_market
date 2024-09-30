RSpec.describe 'PointActivities', type: :system do
  let(:admin) { create(:admin) }
  let(:user) { create(:user, name: 'Alice') }
  let!(:point_activity) { create(:point_activity, point_change: 100, description: '雨の日キャンペーン', user:) }

  before do
    admin_login(admin)
    expect(page).to have_content 'ログインしました。'
  end

  describe 'ユーザーポイント履歴' do
    it 'ポイント情報が表示される' do
      visit admin_user_point_activities_path(user)

      expect(page).to have_css 'h1', text: 'Alice様 ポイント履歴'
      expect(page).to have_content 'ポイント残高: 100'
      expect(page).to have_content '雨の日キャンペーン'
      expect(page).to have_content '100 ポイント'
    end

    it 'ポイント管理画面へ遷移する' do
      visit admin_user_point_activities_path(user)
      click_on 'ポイント管理画面'
      expect(page).to have_css 'h1', text: 'ポイント管理'
    end

    it '前の画面へ戻る' do
      visit admin_user_path(user)

      expect(page).to have_css 'h1', text: '顧客詳細'
      click_on 'ポイント一覧'
      click_on '戻る'

      expect(page).to have_css 'h1', text: '顧客詳細'
    end

    it 'トップへ戻る' do
      visit admin_user_point_activities_path(user)
      click_on 'トップ'
      expect(page).to have_css 'h1', text: '商品一覧(管理画面)'
    end
  end

  describe 'ポイント管理' do
    context 'フォームの値が正常な場合' do
      it 'ポイントを増加させることができる' do
        visit new_admin_user_point_activity_path(user)

        fill_in 'point_activity_point_change', with: 100
        fill_in 'point_activity_description', with: '対象商品購入キャンペーン'
        fill_in 'point_activity_expires_at', with: '2024-10-27'
        click_on 'ポイントを反映させる'

        expect(page).to have_css 'h1', text: 'Alice様 ポイント履歴'
        tr = all('div tbody tr').map(&:text)
        expect(tr[0]).to eq "対象商品購入キャンペーン 100 ポイント 2024年10月27日 #{Date.current.strftime('%Y年%m月%d日')}" # NOTE: 日付は左が有効期限、右が適用日
      end

      it 'ポイントを減少させることができる' do
        visit new_admin_user_point_activity_path(user)

        fill_in 'point_activity_point_change', with: -50
        fill_in 'point_activity_description', with: '失効'
        click_on 'ポイントを反映させる'

        expect(page).to have_css 'h1', text: 'Alice様 ポイント履歴'
        tr = all('div tbody tr').map(&:text)
        expect(tr[0]).to eq "失効 -50 ポイント #{Date.current.strftime('%Y年%m月%d日')}"
      end
    end

    context 'フォームの値が異常な場合' do
      it 'ポイントを増加させることができる' do
        visit new_admin_user_point_activity_path(user)

        fill_in 'point_activity_point_change', with: ''
        fill_in 'point_activity_description', with: ''
        click_on 'ポイントを反映させる'

        expect(page).to have_css 'h1', text: 'ポイント管理'
        expect(page).to have_content '追加ポイントを入力してください'
        expect(page).to have_content '適用理由を入力してください'
      end
    end

    it '前の画面へ戻る' do
      visit admin_user_point_activities_path(user)

      expect(page).to have_css 'h1', text: 'Alice様 ポイント履歴'
      click_on 'ポイント管理画面'
      click_on '戻る'

      expect(page).to have_css 'h1', text: 'Alice様 ポイント履歴'
    end

    it 'トップへ戻る' do
      visit new_admin_user_point_activity_path(user)
      click_on 'トップ'
      expect(page).to have_css 'h1', text: '商品一覧(管理画面)'
    end
  end
end
