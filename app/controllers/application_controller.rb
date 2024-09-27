class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :nickname])
  end

  def current_cart
    if user_signed_in?
      current_cart = current_user.cart || current_user.create_cart!
      if session[:cart_id]
        guest_cart = Cart.find_by(id: session[:cart_id])
        current_cart.merge_guest_cart(guest_cart) if guest_cart.present?
        session.delete(:cart_id)
      end
    else
      current_cart = Cart.find_by(id: session[:cart_id])
      unless current_cart
        current_cart = Cart.create!
        session[:cart_id] = current_cart.id
      end
    end
    current_cart
  end
end
