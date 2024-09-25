RSpec.describe Coupon, type: :model do
  subject { described_class.new(code: '12Ab-cd34-gh78', point: 100, expires_at: Date.current) }

  describe 'バリデーション' do
    it 'バリデーションが有効' do
      expect(subject).to be_valid
    end

    it 'クーポンコードが不正(入力なし)' do
      subject.code = nil
      expect(subject).to_not be_valid
    end

    it 'クーポンコードが不正(一桁多い)' do
      subject.code = '11111-1111-1111'
      expect(subject).to_not be_valid
    end

    it 'クーポンコードが不正(半角英数字以外が含まれている)' do
      subject.code = '1234-abcd-efgあ'
      expect(subject).to_not be_valid
    end

    it 'クーポンコードが不正(ハイフンなし)' do
      subject.code = '1234abcd-5678'
      expect(subject).to_not be_valid
    end

    it 'ポイントが不正(入力なし)' do
      subject.point = nil
      expect(subject).to_not be_valid
    end

    it '有効期限が不正' do
      subject.expires_at = Date.current.ago(1.days)
      expect(subject).to_not be_valid
    end
  end
end
