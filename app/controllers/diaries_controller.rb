class DiariesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]
  before_action :set_diary, only: %i[edit update destroy]
  before_action :authorize_user, only: %i[edit update destroy]

  def index
    @diaries = Diary.order(created_at: :desc)
  end

  def new
    @diary = current_user.diaries.build
  end

  def create
    @diary = current_user.diaries.build(diary_params)
    if @diary.save
      redirect_to diaries_path, notice: '投稿しました。'
    else
      render :new, alert: '投稿に失敗しました。', status: :unprocessable_entity
    end
  end

  def show
    @diary = Diary.find(params[:id])
  end

  def edit
  end

  def update
    if @diary.update(diary_params)
      redirect_to diary_path(@diary), notice: '更新しました。'
    else
      render :edit, alert: '更新に失敗しました。', status: :unprocessable_entity
    end
  end

  def destroy
    @diary.destroy!
    redirect_to diaries_path, notice: '削除しました。'
  end

  private

  def diary_params
    params.require(:diary).permit(:title, :content)
  end

  def set_diary
    @diary = current_user.diaries.find(params[:id])
  end

  def authorize_user
    unless current_user === @diary.user
      redirect_to root_path, alert: '他のユーザーを投稿を操作することはできません。'
    end
  end
end
