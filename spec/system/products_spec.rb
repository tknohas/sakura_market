RSpec.describe 'Products', type: :system do
  let!(:product) { create(:product, name: 'ピーマン', price: 1_000, description: '苦味が少ないです。', sort_position: 1, created_at: '2024-01-01') }

  describe '商品詳細画面' do
    it '商品情報が表示される' do
      visit product_path(product)

      expect(page).to have_css 'h1', text: '商品詳細'
      expect(page).to have_css 'img.product-image'
      expect(page).to have_content 'ピーマン'
      expect(page).to have_content 100
      expect(page).to have_content '苦味が少ないです。'
    end

    it '前の画面へ戻る' do
      visit root_path
      click_on 'ピーマン'
      click_on '戻る'

      expect(page).to have_css 'h1', text: '商品一覧'
    end
  end
end
