# frozen_string_literal: true

class Vendors::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_admin!
  layout 'admins/application'

  def create
    build_resource(sign_up_params)

    if resource.save
      redirect_to admin_vendors_path, notice: '業者が正常に追加されました。'
    else
      clean_up_passwords(resource)
      render :new, status: :unprocessable_entity
    end
  end
end
