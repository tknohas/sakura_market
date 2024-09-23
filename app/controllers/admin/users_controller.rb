class Admin::UsersController < Admin::ApplicationController
  before_action :set_user, only: %i[show update destroy]

  def index
    @users = User.order(:id)
  end

  def show
  end

  def update
    if @user.toggle_availability
      redirect_to admin_users_path, notice: "アカウントを#{@user.availability_status}しました。"
    else
      render :show, alert: '変更に失敗しました。'
    end
  end

  def destroy
    if @user.discard
      redirect_to admin_users_path, notice: '削除に成功しました。'
    else
      redirect_to admin_users_path, notice: '削除に失敗しました。'
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:unavailable)
  end
end
