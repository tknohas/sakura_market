RSpec.describe CouponUsage, type: :model do
  let(:user) { create(:user) }
  let(:coupon) { create(:coupon) }
  subject { described_class.new(user:, coupon:) }

  describe 'バリデーション' do
    it 'バリデーションが有効' do
      expect(subject).to be_valid
    end

    it 'userが不正' do
      subject.user = nil
      expect(subject).to_not be_valid
    end

    it 'couponが不正' do
      subject.coupon = nil
      expect(subject).to_not be_valid
    end
  end
end
