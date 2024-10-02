class Admin::VendorsController < Admin::ApplicationController
  before_action :set_vendor, only: %i[edit update destroy]

  def index
    @vendors = Vendor.order(:id)
  end

  def edit; end

  def update
    if @vendor.update(vendor_params)
      redirect_to admin_vendors_path, notice: '変更しました。'
    else
      flash.now[:alert] = '変更に失敗しました。'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @vendor.destroy!
    redirect_to admin_vendors_path, notice: '削除に成功しました。'
  end

  private

  def vendor_params
    params.require(:vendor).permit(:name, :email)
  end

  def set_vendor
    @vendor = Vendor.find(params[:id])
  end
end
