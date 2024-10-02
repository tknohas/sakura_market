RSpec.describe PointActivity, type: :model do
  let(:user) { create(:user) }
  subject { described_class.new(point_change: 0, description: '雨の日特典', user:) }

  describe 'バリデーション' do
    it 'バリデーションが有効' do
      expect(subject).to be_valid
    end

    it '追加ポイントが不正(入力なし)' do
      subject.point_change = nil
      expect(subject).to_not be_valid
    end

    it '追加ポイントが不正(数値以外を入力)' do
      subject.point_change = 'a'
      expect(subject).to_not be_valid
    end

    it '説明が不正(入力なし)' do
      subject.description = nil
      expect(subject).to_not be_valid
    end

    it '説明が不正(文字数)' do
      subject.description = 'a' * 61
      expect(subject).to_not be_valid
    end

    it 'userが不正' do
      subject.user = nil
      expect(subject).to_not be_valid
    end
  end
end
