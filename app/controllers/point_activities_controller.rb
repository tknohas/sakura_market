class PointActivitiesController < ApplicationController
  def index
    @point_activities = current_user.point_activities.order(created_at: :desc)
  end
end
