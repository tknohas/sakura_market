Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener'
  root to: "home#index"
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    confirmations: 'users/confirmations',
    passwords: 'users/passwords'
  }
end
