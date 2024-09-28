class Vendor::ProductsController < Vendor::ApplicationController
  def index
    @products = Product.includes(:image_attachment).order(:id)
  end
end
