Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener'
  root to: 'diaries#index'
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
    resources :users, only: %i[index show update destroy] do
      resources :point_activities, only: %i[index new create], module: :users
    end
    resources :coupons
  end
  resources :products, only: %i[index show]
  resources :cart_items, only: %i[create destroy]
  resource :cart, only: %i[show]
  resource :address, only: %i[new create edit update]
  resources :purchases, only: %i[index new create show]
  resource :user, only: %i[show edit update] do
    collection do
      patch :cancel
    end
  end
  resources :diaries do
    resources :comments, only: %i[new create edit update destroy], module: :diaries
    resource :likes, only: %i[create destroy], module: :diaries
  end
  resources :coupons, only: %i[index]
  post 'apply_coupon', to: 'coupons#apply'
  post 'apply_point', to: 'purchases#apply'
  resources :point_activities, only: %i[index]
end
