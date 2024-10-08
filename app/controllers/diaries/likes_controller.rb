class Diaries::LikesController < ApplicationController
  before_action :set_diary, only: %i[create destroy]

  def create
    like = @diary.like!(current_user)
    LikeMailer.notify_liked(like).deliver_now
    redirect_back fallback_location: root_path, notice: 'いいねしました！'
  end

  def destroy
    @diary.unlike!(current_user)
    redirect_back fallback_location: root_path, notice: 'いいねを解除しました。'
  end

  private

  def set_diary
    @diary = Diary.find(params[:diary_id])
  end
end
