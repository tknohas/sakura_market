RSpec.describe Stock, type: :model do
  let(:vendor) { create(:vendor) }
  let(:product) { create(:product) }
  subject { described_class.new(quantity: 100, vendor:, product:) }

  describe 'バリデーション' do
    it 'バリデーションが有効' do
      expect(subject).to be_valid
    end

    it '在庫数が不正(0を入力)' do
      subject.quantity = 0
      expect(subject).to_not be_valid
    end

    it '在庫数が不正(入力なし)' do
      subject.quantity = nil
      expect(subject).to_not be_valid
    end

    it 'vendorが不正' do
      subject.vendor = nil
      expect(subject).to_not be_valid
    end

    it 'productが不正' do
      subject.product = nil
      expect(subject).to_not be_valid
    end
  end
end
