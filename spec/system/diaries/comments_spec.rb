RSpec.describe 'Comments', type: :system do
  let(:current_user) { create(:user, name: 'Alice', nickname: 'ありす') }
  let!(:current_user_diary) { create(:diary, title: 'さくらんぼが届きました。', content: '家族みんなで食べる予定です。', user: current_user) }
  let!(:current_user_comment) { create(:comment, content: '我が家にもさくらんぼが届きました。', user: current_user, diary: current_user_diary) }
  let(:user) { create(:user, name: 'Bob', nickname: 'bb') }
  let!(:user_comment) { create(:comment, content: '食パンにアボカドを塗って食べると美味しいですよ！', user:, diary: current_user_diary) }
  let!(:user_diary) { create(:diary, title: '大きなアボカドを購入しました。', content: 'サイズの大きなアボカドが売っていたので買ってみました。', user:) }

  before do
    user_login(current_user)
    expect(page).to have_content 'ログインしました。'
  end

  describe '日記に紐づくコメント一覧' do
    it '日記詳細画面にコメントが表示される' do
      visit diary_path(current_user_diary)

      expect(page).to have_css 'h1', text: '日記詳細'
      expect(page).to have_content 'ありす'
      expect(page).to have_content '我が家にもさくらんぼが届きました。'
      expect(page).to have_content 'bb'
      expect(page).to have_content '食パンにアボカドを塗って食べると美味しいですよ！'
    end

    it 'コメント編集画面へ遷移する' do
      visit diary_path(current_user_diary)

      comments = all('.comment-area')
      within comments[1] do
        click_on '編集'
      end

      expect(page).to have_css 'h1', text: 'コメント編集'
    end

    it 'コメントを削除できる', :js do
      visit diary_path(current_user_diary)

      expect(page).to have_css 'h1', text: '日記詳細'
      expect{
        comments = all('.comment-area')
        within comments[1] do
          click_on '削除'
        end
        expect(page.accept_confirm).to eq '本当に削除しますか？'
        expect(page).to have_content 'コメントを削除しました。'
      }.to change(Comment, :count).by(-1)
    end

    it '投稿したユーザー以外に編集ボタンは表示されない' do
      visit diary_path(current_user_diary)

      comments = all('.comment-area')
      within comments[0] do
        expect(page).to_not have_content '編集'
      end
    end

    it '投稿したユーザー以外に削除ボタンは表示されない' do
      visit diary_path(current_user_diary)

      comments = all('.comment-area')
      within comments[0] do
        expect(page).to_not have_content '削除'
      end
    end
  end

  describe 'コメント追加' do
    context 'フォームの入力値が正常な場合' do
      it 'コメントを追加できる' do
        click_on 'コメントを書く'

        fill_in 'comment_content', with: '冷えてきたのでじゃがバターがより美味しく感じますね。'
        click_on 'コメントする'

        expect(page).to have_css 'h1', text: '日記詳細'
        comments = all('.comment-area')
        within comments[0] do
          expect(page).to have_content '冷えてきたのでじゃがバターがより美味しく感じますね。'
        end
      end

      it 'コメントを追加すると日記を書いたユーザーにメールが送信される' do
        click_on 'コメントを書く'

        fill_in 'comment_content', with: '冷えてきたのでじゃがバターがより美味しく感じますね。'
        click_on 'コメントする'

        email = open_last_email
        expect(email).to have_subject 'ありすさんがあなたの日記にコメントしました'
        expect(email.body).to have_content '冷えてきたのでじゃがバターがより美味しく感じますね'
        click_first_link_in_email(email)

        expect(page).to have_css 'h1', text: '日記詳細'
      end
    end

    context 'フォームの入力値が異常な場合' do
      it 'エラーメッセージが表示される' do
        click_on 'コメントを書く'

        fill_in 'comment_content', with: ''
        click_on 'コメントする'

        expect(page).to have_css 'h1', text: 'コメント追加'
        expect(page).to have_content 'コメント内容を入力してください'
      end
    end

    it '前の画面へ遷移する' do
      visit diaries_path

      expect(page).to have_css 'h1', text: '日記一覧'
      click_on 'コメントを書く'
      click_on '戻る'

      expect(page).to have_css 'h1', text: '日記一覧'
    end

    it 'トップ画面へ遷移する' do
      click_on 'コメントを書く'

      expect(page).to have_css 'h1', text: 'コメント追加'
      click_on 'トップ'

      expect(page).to have_css 'h1', text: '日記一覧'
    end

    it '自身(Alice)の投稿には「コメントを書く」リンクが表示されない' do
      diaries = all('.container .bg-white').map(&:text)
      expect(diaries[0]).to eq "大きなアボカドを購入しました。\nbb\nサイズの大きなアボカドが売っていたので買ってみました。\nコメントを書く\nthumb_up"
      expect(diaries[1]).to eq "さくらんぼが届きました。\nありす\n家族みんなで食べる予定です。"
    end
  end

  describe 'コメント編集' do
    context 'フォームの入力値が正常な場合' do
      it 'コメント内容を更新できる' do
        visit edit_diary_comment_path(current_user_diary, current_user_comment)

        fill_in 'comment_content', with: '冷えてきたのでじゃがバターがより美味しく感じますね。'
        click_on '内容を更新する'

        expect(page).to have_css 'h1', text: '日記詳細'
        comments = all('.comment-area')
        within comments[1] do
          expect(page).to have_content '冷えてきたのでじゃがバターがより美味しく感じますね。'
        end
      end
    end

    context 'フォームの入力値が異常な場合' do
      it 'エラーメッセージが表示される' do
        visit edit_diary_comment_path(current_user_diary, current_user_comment)

        fill_in 'comment_content', with: ''
        click_on '内容を更新する'

        expect(page).to have_css 'h1', text: 'コメント編集'
        expect(page).to have_content 'コメント内容を入力してください'
      end
    end

    it '前の画面へ遷移する' do
      visit diary_path(current_user_diary)

      expect(page).to have_css 'h1', text: '日記詳細'
      comments = all('.comment-area')
      within comments[1] do
        click_on '編集'
      end

      expect(page).to have_css 'h1', text: 'コメント編集'
      click_on '戻る'

      expect(page).to have_css 'h1', text: '日記詳細'
    end

    it 'トップ画面へ遷移する' do
      visit edit_diary_comment_path(current_user_diary, current_user_comment)

      expect(page).to have_css 'h1', text: 'コメント編集'
      click_on 'トップ'
      expect(page).to have_css 'h1', text: '日記一覧'
    end
  end
end
