class Vendor::ApplicationController < ApplicationController
  before_action :authenticate_vendor!
  skip_before_action :authenticate_user!
  layout 'vendors/application'
end
