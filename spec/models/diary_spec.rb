RSpec.describe Diary, type: :model do
  let(:user) { create(:user) }
  subject { described_class.new(title: 'さくらんぼが届きました。', content: '家族で食べる予定です。', user:) }

  describe 'バリデーション' do
    it 'バリデーションが有効' do
      expect(subject).to be_valid
    end

    it 'タイトルが不正(入力なし)' do
      subject.title = nil
      expect(subject).to_not be_valid
    end

    it 'タイトルが不正(文字数)' do
      subject.title = 'a' * 61
      expect(subject).to_not be_valid
    end

    it '内容が不正(入力なし)' do
      subject.content = nil
      expect(subject).to_not be_valid
    end

    it '内容が不正(文字数)' do
      subject.content = 'a' * 501
      expect(subject).to_not be_valid
    end

    it 'userが不正' do
      subject.user = nil
      expect(subject).to_not be_valid
    end
  end
end
