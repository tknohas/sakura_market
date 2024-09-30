RSpec.describe CartItem, type: :model do
  let(:user) { create(:user) }
  let(:vendor) { create(:vendor) }
  let!(:product) { create(:product) }
  let!(:stock) { create(:stock, vendor:, product:) }
  let!(:cart) { create(:cart, user:) }
  subject { described_class.new(cart:, product:, vendor:) }

  describe 'バリデーション' do
    it 'バリデーションが有効' do
      expect(subject).to be_valid
    end

    it '商品数が有効' do
      subject.quantity = 10
      expect(subject).to be_valid
    end

    it 'productが不正' do
      subject.product = nil
      expect(subject).to_not be_valid
    end


    it '商品数が不正' do
      subject.quantity = 10
      subject.quantity = 9
      expect(subject).to_not be_valid
    end

    it 'cartが不正' do
      subject.cart = nil
      expect(subject).to_not be_valid
    end

  end
end
