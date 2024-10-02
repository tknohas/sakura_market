RSpec.describe Product, type: :model do
  subject { described_class.new( name: 'ピーマン', price: 1_000, description: '苦味が少ないです。', sort_position: 1) }

  describe 'バリデーション' do
    it 'バリデーションが有効' do
      expect(subject).to be_valid
    end

    it '商品名が不正(入力なし)' do
      subject.name = nil
      expect(subject).to_not be_valid
    end

    it '商品名が不正(文字数)' do
      subject.name = 'a' * 21
      expect(subject).to_not be_valid
    end

    it '価格が不正(入力なし)' do
      subject.price = nil
      expect(subject).to_not be_valid
    end

    it '価格が不正(数値以外を入力)' do
      subject.price = 'a'
      expect(subject).to_not be_valid
    end

    it '商品説明が不正(入力なし)' do
      subject.description = nil
      expect(subject).to_not be_valid
    end

    it '商品説明が不正(文字数)' do
      subject.description = 'a' * 601
      expect(subject).to_not be_valid
    end
  end
end
