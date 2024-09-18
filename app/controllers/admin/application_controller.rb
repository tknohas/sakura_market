class Admin::ApplicationController < ApplicationController
  before_action :authenticate_admin!

  layout 'admins/application'
end
