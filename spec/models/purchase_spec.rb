RSpec.describe Purchase, type: :model do
  let(:user) { create(:user) }
  subject { described_class.new(delivery_date: 3.business_days.after(Date.current), delivery_time: '指定なし', user:) }

  before do
    stub_const("#{Purchase}::SHIPPING_FEE_PER_TIER", 600)
    stub_const("#{Purchase}::SHIPPING_TIER_COUNT", 5)
  end

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

    it '配達時間が不正' do
      subject.delivery_time = nil
      expect(subject).to_not be_valid
    end

    it 'userが不正' do
      subject.user = nil
      expect(subject).to_not be_valid
    end

    it '決済方法が不正' do
      subject.payment_method = nil
      expect(subject).to_not be_valid
    end
  end

  describe '送料の計算' do
    it 'total_quantityが1であれば600を返す' do
      allow(subject).to receive(:total_quantity).and_return(1)
      expect(subject.calculate_shipping_fee).to eq 600
    end

    it 'total_quantityが5であれば600を返す' do
      allow(subject).to receive(:total_quantity).and_return(5)
      expect(subject.calculate_shipping_fee).to eq 600
    end

    it 'total_quantityが6であれば1200を返す' do
      allow(subject).to receive(:total_quantity).and_return(6)
      expect(subject.calculate_shipping_fee).to eq 1_200
    end

    it 'total_quantityが10であれば1200を返す' do
      allow(subject).to receive(:total_quantity).and_return(10)
      expect(subject.calculate_shipping_fee).to eq 1_200
    end

    it 'total_quantityが11であれば1800を返す' do
      allow(subject).to receive(:total_quantity).and_return(11)
      expect(subject.calculate_shipping_fee).to eq 1_800
    end
  end

  describe '代引き手数料の計算' do
    it '小計が0であれば300を返す' do
      expect(subject.cash_on_delivery_fee(0)).to eq 300
    end

    it '小計が9_999であれば300を返す' do
      expect(subject.cash_on_delivery_fee(9_999)).to eq 300
    end

    it '小計が10_000であれば400を返す' do
      expect(subject.cash_on_delivery_fee(10_000)).to eq 400
    end

    it '小計が29_999であれば400を返す' do
      expect(subject.cash_on_delivery_fee(29_999)).to eq 400
    end

    it '小計が30_000であれば600を返す' do
      expect(subject.cash_on_delivery_fee(30_000)).to eq 600
    end

    it '小計が99_999であれば600を返す' do
      expect(subject.cash_on_delivery_fee(99_999)).to eq 600
    end

    it '小計が100_000であれば1_000を返す' do
      expect(subject.cash_on_delivery_fee(100_000)).to eq 1_000
    end
  end
end
