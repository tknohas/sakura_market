RSpec.describe 'Comments', type: :system do
  let(:current_user) { create(:user, name: 'Alice', nickname: 'ありす') }
  let!(:current_user_diary) { create(:diary, title: 'さくらんぼが届きました。', content: '家族みんなで食べる予定です。', user: current_user) }
  let!(:current_user_like) { create(:like, user: current_user, diary: current_user_diary) }
  let(:user) { create(:user, name: 'Bob', email: 'bob@example.com', nickname: 'bb') }
  let!(:user_diary) { create(:diary, title: '大きなアボカドを購入しました。', content: 'サイズの大きなアボカドが売っていたので買ってみました。', user:) }
  let!(:like) { create(:like, user:, diary: user_diary) }

  before do
    user_login(current_user)
    expect(page).to have_content 'ログインしました。'
  end

  describe 'いいね' do
    it '「いいね」することができる' do
      expect(page).to have_css 'h1', text: '日記一覧'
      click_on 'thumb_up'

      expect(page).to have_content 'いいねしました！'
      expect(page).to have_css 'span.material-symbols-outlined.text-blue-500'
    end

    it '「いいね」を解除できる' do
      expect(page).to have_css 'h1', text: '日記一覧'
      click_on 'thumb_up'

      expect(page).to have_content 'いいねしました！'
      expect(page).to have_css 'span.material-symbols-outlined.text-blue-500'
      click_on 'thumb_up'

      expect(page).to have_content 'いいねを解除しました。'
      expect(page).to have_css 'span.material-symbols-outlined'
    end

    it '自身(Alice)の日記には「いいね」ボタンが表示されない' do
      expect(page).to have_css 'h1', text: '日記一覧'
      texts = all('.container .bg-white').map(&:text)
      expect(texts[0]).to eq "大きなアボカドを購入しました。\nbb\nサイズの大きなアボカドが売っていたので買ってみました。\nコメントを書く\nthumb_up"
      expect(texts[1]).to eq "さくらんぼが届きました。\nありす\n家族みんなで食べる予定です。"
    end

    it 'ログイン前は「いいね」ボタンが表示されない', :js do
      click_on 'ログアウト'

      expect(page.accept_confirm).to eq 'ログアウトしますか？'
      click_on 'さくらマーケット'
      expect(page).to have_css 'h1', text: '日記一覧'
      texts = all('.container.flex .mr-8.w-full a').map(&:text)
      expect(texts[0]).to eq "大きなアボカドを購入しました。\nbb\nサイズの大きなアボカドが売っていたので買ってみました。"
      expect(texts[1]).to eq "さくらんぼが届きました。\nありす\n家族みんなで食べる予定です。"
    end

    it '「いいね」された日記のユーザーにメールが送信される' do
      expect(page).to have_css 'h1', text: '日記一覧'
      click_on 'thumb_up'

      email = open_last_email
      expect(email).to have_subject 'ありすさんがあなたの日記にいいねしました'
      expect(email.body).to have_content '大きなアボカドを購入しました。'
      expect(email.to).to eq ['bob@example.com']
      click_first_link_in_email(email)

      expect(page).to have_css 'h1', text: '日記詳細'
    end
  end
end
