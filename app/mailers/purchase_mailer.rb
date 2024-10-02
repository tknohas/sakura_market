class PurchaseMailer < ApplicationMailer
  def notify_completed(purchase)
    @purchase = purchase
    mail(to: purchase.user.email, subject: '購入が完了しました。')
  end

  def notify_sold(purchase)
    vendor = purchase.purchase_items.includes(:vendor).first.vendor
    @vendor = vendor
    @purchase = purchase
    mail(to: vendor.email, subject: '商品が購入されました。')
  end
end
