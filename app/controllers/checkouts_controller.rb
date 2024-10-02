class CheckoutsController < ApplicationController
  def create
    purchase = current_user.purchases.build
    line_items = current_user.line_items_checkout
    session = create_session(line_items, purchase)
    redirect_to session.url, allow_other_host: true
  end

  private

  def create_session(line_items, purchase)
    Stripe::Checkout::Session.create(
      client_reference_id: current_user.id,
      customer_email: current_user.email,
      mode: 'payment',
      payment_method_types: ['card'],
      line_items:,
      shipping_address_collection: {
        allowed_countries: ['JP']
      },
      shipping_options: [
        {
          shipping_rate_data: {
            type: 'fixed_amount',
            fixed_amount: {
              amount: (purchase.calculate_shipping_fee * 1.1).floor,
              currency: 'jpy'
            },
            display_name: '全国一律'
          },
        }
      ],
      success_url: root_url,
      cancel_url: cart_url
    )
  end
end
