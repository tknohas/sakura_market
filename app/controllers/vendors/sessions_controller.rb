# frozen_string_literal: true

class Vendors::SessionsController < Devise::SessionsController
  layout 'vendors/application'

  def after_sign_in_path_for(resource)
    if resource.password_changed
      vendor_products_path
    else
      edit_vendor_registration_path
    end
  end

  def after_sign_out_path_for(resource)
    new_vendor_session_path
  end
end
