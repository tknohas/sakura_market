class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!, only: [:create]

  def create
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.application.credentials.dig(:stripe, :endpoint_secret)

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      Rails.logger.error "Webhook error: #{e.message}"
      render json: { error: e.message }, status: :bad_request
      return
    end
    handle_event(event)
    head :ok
  end

  private

  def handle_event(event)
    case event.type
    when 'checkout.session.completed'
      handle_checkout_session_completed(event.data.object)
    else
      Rails.logger.info "Unhandled event type: #{event.type}"
    end
  end

  def handle_checkout_session_completed(session)
    user = User.find_by(id: session.client_reference_id)
    return unless user

    ActiveRecord::Base.transaction do
      purchase = create_purchase(session)
      session_with_expand = Stripe::Checkout::Session.retrieve({ id: session.id, expand: ['line_items'] })
      session_with_expand.line_items.data.each do |line_item|
        create_purchase_items(purchase, line_item)
      end
      user.cart.cart_items_destroy!
    end
  end

  def create_purchase(session)
    Purchase.create!({
      user_id: session.client_reference_id,
      delivery_time: '指定なし',
      payment_method: :card
    })
  end

  def create_purchase_items(purchase, line_item)
    product = Stripe::Product.retrieve(line_item.price.product)
    purchased_product = Product.find(product.metadata.product_id)
    vendor = Vendor.find_by(id: product.metadata.vendor_id)
    raise ActiveRecord::RecordNotFound, "Product not found: #{product.metadata.product_id}" if purchased_product.nil?

    purchase.purchase_items.create!(
      product: purchased_product,
      vendor: vendor,
      quantity: line_item.quantity
    )
    purchase.update_stock_after_card_purchase(purchased_product, vendor, line_item.quantity)
  end
end
