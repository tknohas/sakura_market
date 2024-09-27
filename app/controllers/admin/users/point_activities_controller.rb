class Admin::Users::PointActivitiesController < Admin::ApplicationController
  before_action :set_user, only: %i[index new create]

  def index
    @point_activities = @user.point_activities.order(created_at: :desc)
  end

  def new
    @point_activity = @user.point_activities.build
  end

  def create
    @point_activity = @user.point_activities.build(point_activity_params)
    if @point_activity.save
      redirect_to admin_user_point_activities_path(@user), notice: 'ポイントを更新しました。'
    else
      render :new, alert: 'ポイントの更新に失敗しました。', status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def point_activity_params
    params.require(:point_activity).permit(:point_change, :description, :expires_at)
  end
end
