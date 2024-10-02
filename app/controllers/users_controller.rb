class UsersController < ApplicationController
  def edit; end

  def update
    if current_user.update(user_params)
      redirect_to root_path, notice: 'プロフィールを変更しました。'
    else
      render :edit, alert: '変更に失敗しました。', status: :unprocessable_entity
    end
  end

  def cancel
    if current_user.update(canceled_at: Time.current)
      sign_out current_user
      redirect_to root_path, notice: '退会処理が完了しました。'
    else
      redirect_to root_path, notice: '退会処理に失敗しました。'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :nickname, :image)
  end
end
