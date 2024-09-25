class Diaries::CommentsController < ApplicationController
  before_action :set_diary, only: %i[new create edit update destroy]
  before_action :set_comment, only: %i[edit update destroy]
  before_action :authorize_user, only: %i[edit update destroy]

  def new
    @comment = @diary.comments.build
  end

  def create
    @comment = @diary.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      redirect_to diary_path(@diary), notice: 'コメントしました。'
    else
      render :new, alert: 'コメントに失敗しました。', status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @comment.update(comment_params)
      redirect_to diary_path(@diary), notice: '内容を更新しました。'
    else
      render :edit, alert: '更新に失敗しました。', status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy!
    redirect_to diary_path(@diary), notice: 'コメントを削除しました。'
  end

  private

  def set_diary
    @diary = Diary.find(params[:diary_id])
  end

  def set_comment
    @comment = @diary.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end

  def authorize_user
    unless current_user === @comment.user
      redirect_to root_path, alert: '他のユーザーを投稿を操作することはできません。'
    end
  end
end
