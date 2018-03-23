Rails.application.routes.draw do
  root 'home#index'

  devise_for :users, path: 'auth', controllers: {confirmations: 'confirmations'}

  resources :affiliates, module: :company
  resources :companies
end
