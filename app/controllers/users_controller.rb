class UsersController < ApplicationController
  def cancel
    if current_user.update(canceled_at: Time.current)
      sign_out current_user
      redirect_to root_path, notice: '退会処理が完了しました。'
    else
      redirect_to root_path, notice: '退会処理に失敗しました。'
    end
  end
end
