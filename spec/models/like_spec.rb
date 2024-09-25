RSpec.describe Like, type: :model do
  let(:user) { create(:user) }
  let(:diary) { create(:diary, user:) }
  subject { described_class.new(user:, diary:) }

  describe 'バリデーション' do
    it 'バリデーションが有効' do
      expect(subject).to be_valid
    end

    it 'diaryが不正' do
      subject.diary = nil
      expect(subject).to_not be_valid
    end

    it 'ユーザーが不正' do
      subject.user = nil
      expect(subject).to_not be_valid
    end
  end
end
