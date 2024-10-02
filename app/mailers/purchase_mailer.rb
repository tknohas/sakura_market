class PurchaseMailer < ApplicationMailer
  def notify_completed(purchase)
    @purchase = purchase
    mail(to: purchase.user.email, subject: '購入が完了しました。')
  end
end
