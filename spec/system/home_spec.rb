RSpec.describe 'Home', type: :system do
  let!(:product) { create(:product, name: 'ピーマン', price: 1_000, description: '苦味が少ないです。', sort_position: 1, created_at: '2024-01-01') }

  describe '一覧画面' do
    let(:admin) { create(:admin) }
    let!(:highest_price_product) { create(:product, name: 'にんじん', price: 10_000, sort_position: 3, created_at: '2024-04-01') }
    let!(:lowest_price_product) { create(:product, name: '玉ねぎ', price: 100, sort_position: 2, created_at: '2024-07-01') }

    it '商品情報が表示される' do
      visit root_path

      expect(page).to have_css 'h1', text: '商品一覧'
      expect(page).to have_css 'img.product-image'
      expect(page).to have_content 'ピーマン'
    end

    it '価格が安い順に並び替わる', js: true do
      admin_login(admin)
      select '価格が安い順', from: 'sort_order'
      visit root_path

      expect(page).to have_css 'h1', text: '商品一覧'
      products = all('div a p').map(&:text)
      expect(products).to eq ['玉ねぎ', 'ピーマン', 'にんじん']
    end

    it '価格が高い順に並び替わる', js: true do
      admin_login(admin)
      select '価格が高い順', from: 'sort_order'
      visit root_path

      expect(page).to have_css 'h1', text: '商品一覧'
      products = all('div a p').map(&:text)
      expect(products).to eq ['にんじん', 'ピーマン', '玉ねぎ']
    end

    it '表示順に並び替わる', js: true do
      admin_login(admin)
      select '表示順', from: 'sort_order'
      visit root_path

      expect(page).to have_css 'h1', text: '商品一覧'
      products = all('div a p').map(&:text)
      expect(products).to eq ['ピーマン', '玉ねぎ', 'にんじん']
    end

    it '新着順に並び替わる', js: true do
      admin_login(admin)
      select '新着順', from: 'sort_order'
      visit root_path

      expect(page).to have_css 'h1', text: '商品一覧'
      products = all('div a p').map(&:text)
      expect(products).to eq ['玉ねぎ', 'にんじん', 'ピーマン']
    end
  end
end
