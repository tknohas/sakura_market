class CommentMailer < ApplicationMailer
  def notify_commented(comment)
    @comment = comment
    mail(to: comment.diary.user.email, subject: "#{comment.user.nickname}さんがあなたの日記にコメントしました")
  end
end
