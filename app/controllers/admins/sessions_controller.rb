# frozen_string_literal: true

class Admins::SessionsController < Devise::SessionsController
  layout 'admins/application'

  def after_sign_in_path_for(resource)
    admin_root_path
  end

  def after_sign_out_path_for(resource)
    new_admin_session_path
  end
end
