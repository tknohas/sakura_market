RSpec.describe User, type: :model do
  let(:user) { create(:user) }
  subject { described_class.new(name: 'Alice', email: 'alice@example.com', password: 'Abcd1234') }

  describe "バリデーション" do
    it "バリデーションが有効" do
      expect(subject).to be_valid
    end

    it "名前が不正" do
      subject.name = nil
      expect(subject).to_not be_valid
    end

    it "メールアドレスが不正" do
      subject.email = nil
      expect(subject).to_not be_valid
    end

    it "パスワードが不正(入力なし)" do
      subject.password = nil
      expect(subject).to_not be_valid
    end

    it "パスワードが不正(文字数不足)" do
      subject.password = '123456'
      expect(subject).to_not be_valid
    end

    it "パスワードが不正(条件を満たしていない)" do
      subject.password = 'abcd1234'
      expect(subject).to_not be_valid
    end
  end
end
