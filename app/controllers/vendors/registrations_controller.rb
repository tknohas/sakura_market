# frozen_string_literal: true

class Vendors::RegistrationsController < Devise::RegistrationsController
  skip_before_action :require_no_authentication, only: [:new, :create]
  before_action :authenticate_admin!, only: %i[new create]
  layout :switch_layout

  def create
    build_resource(sign_up_params)

    if admin_signed_in? && resource.save
      redirect_to admin_vendors_path, notice: '業者が正常に追加されました。'
    else
      clean_up_passwords(resource)
      render :new, status: :unprocessable_entity
    end
  end

  def after_update_path_for(resource)
    resource.update!(password_changed: true)
    vendor_products_path
  end

  private

  def switch_layout
    action_name === 'new' ? 'admins/application' : 'vendors/application'
  end
end
