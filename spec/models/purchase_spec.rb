RSpec.describe Purchase, type: :model do
  let(:user) { create(:user) }
  let!(:purchase) { create(:purchase, user:, delivery_time: '指定なし') }
  subject { described_class.new(delivery_date: 3.business_days.after(Date.current), user:) }

  describe 'バリデーション' do
    it '3営業日目だとバリデーションが有効' do
      expect(subject).to be_valid
    end

    it '14営業日目だとバリデーションが有効' do
      subject.delivery_date = 14.business_days.after(Date.current)
      expect(subject).to be_valid
    end

    it '2営業日目だとバリデーションが無効' do
      subject.delivery_date = 2.business_days.after(Date.current)
      expect(subject).to_not be_valid
    end

    it '15営業日目だとバリデーションが無効' do
      subject.delivery_date = 15.business_days.after(Date.current)
      expect(subject).to_not be_valid
    end
  end
end
