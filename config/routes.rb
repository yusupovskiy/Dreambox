Rails.application.routes.draw do
  root 'home#index'

  devise_for :users, path: 'auth', controllers: {confirmations: 'confirmations'}

  resources :companies do
    resources :affiliates, module: :company
    resources :clients, module: :company
  end
end
