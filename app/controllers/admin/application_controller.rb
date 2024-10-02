class Admin::ApplicationController < ApplicationController
  before_action :authenticate_admin!
  skip_before_action :authenticate_user!
  layout 'admins/application'
end
