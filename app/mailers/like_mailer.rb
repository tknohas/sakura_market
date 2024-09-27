class LikeMailer < ApplicationMailer
  def notify_liked(like)
    @like = like
    mail(to: like.diary.user.email, subject: "#{like.user.nickname}さんがあなたの日記にいいねしました")
  end
end
