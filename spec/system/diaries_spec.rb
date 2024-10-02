RSpec.describe 'Diaries', type: :system do
  let(:current_user) { create(:user, name: 'Alice', nickname: 'ありす') }
  let!(:current_user_diary) { create(:diary, title: 'さくらんぼが届きました。', content: '家族みんなで食べる予定です。', user: current_user) }
  let(:user) { create(:user, name: 'Bob', nickname: 'bb') }
  let!(:user_diary) { create(:diary, title: '大きなアボカドを購入しました。', content: 'サイズの大きなアボカドが売っていたので買ってみました。', user:) }

  before do
    user_login(current_user)
    expect(page).to have_content 'ログインしました。'
  end

  describe '日記一覧' do
    it '日記が表示される' do
      expect(page).to have_css 'img.user-image'
      expect(page).to have_css 'h1', text: '日記一覧'
      expect(page).to have_content 'さくらんぼが届きました。'
      expect(page).to have_content 'ありす'
      expect(page).to have_content '家族みんなで食べる予定です。'
      expect(page).to have_content '大きなアボカドを購入しました。'
      expect(page).to have_content 'bb'
      expect(page).to have_content 'サイズの大きなアボカドが売っていたので買ってみました。'
    end

    it '日記投稿画面へ遷移する' do
      click_on '日記の投稿はこちら'
      expect(page).to have_css 'h1', text: '日記投稿'
    end

    it '日記詳細画面へ遷移する' do
      click_on 'さくらんぼが届きました。'
      expect(page).to have_css 'h1', text: '日記詳細'
    end

    it '商品一覧画面へ遷移する' do
      click_on '商品一覧'
      expect(page).to have_css 'h1', text: '商品一覧'
    end

    it 'プロフィール編集画面へ遷移する' do
      click_on 'プロフィールを編集する'
      expect(page).to have_css 'h1', text: 'プロフィール編集'
    end

    it 'ログイン情報編集画面へ遷移する' do
      click_on 'ログイン情報を編集する'
      expect(page).to have_css 'h1', text: 'ログイン情報編集'
    end
  end

  describe '日記投稿' do
    context 'フォームの入力値が正常な場合' do
      it '日記を投稿できる' do
        visit new_diary_path

        fill_in 'diary_title', with: 'じゃがバターを作りました。'
        fill_in 'diary_content', with: 'ホクホクで美味しかったです。'
        attach_file 'diary_image', file_fixture('test_image.jpg')
        click_on '日記を投稿する'

        expect(page).to have_css 'h1', text: '日記一覧'
        expect(page).to have_css 'img.diary-image'
        expect(page).to have_content 'じゃがバターを作りました。'
        expect(page).to have_content 'ホクホクで美味しかったです。'
      end
    end

    context 'フォームの入力値が異常な場合' do
      it 'エラーメッセージが表示される' do
        visit new_diary_path

        fill_in 'diary_title', with: ''
        fill_in 'diary_content', with: ''
        click_on '日記を投稿する'

        expect(page).to have_css 'h1', text: '日記投稿'
        expect(page).to have_content 'タイトルを入力してください'
        expect(page).to have_content '投稿内容を入力してください'
      end
    end

    it '前の画面へ遷移する' do
      expect(page).to have_css 'h1', text: '日記一覧'

      click_on '日記の投稿はこちら'
      click_on '戻る'

      expect(page).to have_css 'h1', text: '日記一覧'
    end
  end

  describe '日記詳細' do
    it '日記が表示される' do
      visit diary_path(current_user_diary)

      expect(page).to have_css 'h1', text: '日記詳細'
      expect(page).to have_content 'さくらんぼが届きました。'
      expect(page).to have_content '家族みんなで食べる予定です。'
    end

    it '日記を削除できる', :js do
      visit diary_path(current_user_diary)

      expect(page).to have_css 'h1', text: '日記詳細'
      expect {
        click_on '削除'
        expect(page.accept_confirm).to eq '本当に削除しますか？'
        expect(page).to have_content '削除しました。'
      }.to change(Diary, :count).by(-1)
    end

    it '編集画面へ遷移する' do
      visit diary_path(current_user_diary)
      click_on '編集'
      expect(page).to have_css 'h1', text: '日記編集'
    end

    it '前の画面へ遷移する' do
      expect(page).to have_css 'h1', text: '日記一覧'

      click_on 'さくらんぼが届きました。'
      click_on '戻る'

      expect(page).to have_css 'h1', text: '日記一覧'
    end

    it 'トップ画面へ遷移する' do
      visit diary_path(current_user_diary)
      click_on 'トップ'
      expect(page).to have_css 'h1', text: '日記一覧'
    end

    it '自身の投稿ではなければ編集ボタンが表示されない' do
      visit diary_path(user_diary)
      expect(page).to_not have_content '編集'
    end

    it '自身の投稿ではなければ削除ボタンが表示されない' do
      visit diary_path(user_diary)
      expect(page).to_not have_content '削除'
    end
  end

  describe '日記編集' do
    context 'フォームの入力値が正常な場合' do
      it '日記を更新できる' do
        visit edit_diary_path(current_user_diary)

        fill_in 'diary_title', with: 'じゃがバターを作りました。'
        fill_in 'diary_content', with: 'ホクホクで美味しかったです。'
        attach_file 'diary_image', file_fixture('test_image.jpg')
        click_on '内容を更新する'

        expect(page).to have_css 'h1', text: '日記詳細'
        expect(page).to have_css 'img.diary-image'
        expect(page).to have_content 'じゃがバターを作りました。'
        expect(page).to have_content 'ホクホクで美味しかったです。'
      end
    end

    context 'フォームの入力値が異常な場合' do
      it 'エラーメッセージが表示される' do
        visit edit_diary_path(current_user_diary)

        fill_in 'diary_title', with: ''
        fill_in 'diary_content', with: ''
        click_on '内容を更新する'

        expect(page).to have_css 'h1', text: '日記編集'
        expect(page).to have_content 'タイトルを入力してください'
        expect(page).to have_content '投稿内容を入力してください'
      end
    end

    it '前の画面へ遷移する' do
      visit diary_path(current_user_diary)

      expect(page).to have_css 'h1', text: '日記詳細'
      click_on '編集'
      click_on '戻る'

      expect(page).to have_css 'h1', text: '日記詳細'
    end

    it 'トップ画面へ遷移する' do
      visit edit_diary_path(current_user_diary)
      click_on 'トップ'
      expect(page).to have_css 'h1', text: '日記一覧'
    end
  end
end
