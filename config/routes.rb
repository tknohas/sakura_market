Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener'
  root to: 'home#index'
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    confirmations: 'users/confirmations',
    passwords: 'users/passwords',
  }
  devise_for :admins, controllers: {
    sessions: 'admins/sessions',
  }
  namespace :admin do
    resources :products
  end
  resources :products, only: %i[show]
  resources :cart_items, only: %i[create destroy]
  resource :cart, only: %i[show]
  resource :address, only: %i[new create edit update]
  resources :purchases, only: %i[index new create show]
end
