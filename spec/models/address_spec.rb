RSpec.describe Address, type: :model do
  let(:user) { create(:user) }
  let(:address) { create(:address) }
  subject { described_class.new(postal_code: '123-4567', prefecture: '東京都', city: '渋谷区', street: '渋谷1-1-1', user:) }

  describe 'バリデーション' do
    it 'バリデーションが有効' do
      expect(subject).to be_valid
    end

    it '郵便番号が不正(入力なし)' do
      subject.postal_code = nil
      expect(subject).to_not be_valid
    end

    it '郵便番号が不正(文字数)' do
      subject.postal_code = '1234-5678'
      expect(subject).to_not be_valid
    end

    it '郵便番号が不正(ハイフンなし)' do
      subject.postal_code = '1234567'
      expect(subject).to_not be_valid
    end

    it '都道府県が不正(入力なし)' do
      subject.prefecture = nil
      expect(subject).to_not be_valid
    end

    it '都道府県が不正(文字数)' do
      subject.prefecture = '神奈川県県'
      expect(subject).to_not be_valid
    end

    it '都道府県が不正(最後の文字が都道府県のいずれでもない)' do
      subject.prefecture = '東京'
      expect(subject).to_not be_valid
    end

    it '市区町村が不正' do
      subject.city = nil
      expect(subject).to_not be_valid
    end

    it 'それ以降の住所が不正' do
      subject.street = nil
      expect(subject).to_not be_valid
    end
  end
end
