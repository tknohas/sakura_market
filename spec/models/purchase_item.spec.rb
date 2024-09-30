RSpec.describe PurchaseItem, type: :model do
  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let(:vendor) { create(:vendor) }
  let(:purchase) { create(:purchase, user:) }
  subject { described_class.new(product:, purchase:, vendor:) }

  describe 'バリデーション' do
    it 'バリデーションが有効' do
      expect(subject).to be_valid
    end

    it 'productが不正' do
      subject.product = nil
      expect(subject).to_not be_valid
    end

    it 'vendorが不正' do
      subject.vendor = nil
      expect(subject).to_not be_valid
    end
  end
end
