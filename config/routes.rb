Rails.application.routes.draw do
  namespace :company do
    get 'crm/index'
  end

  root 'home#index'

  devise_for :users, path: 'auth', controllers: {confirmations: 'confirmations'}

  resources :companies do
    resources :affiliates, module: :company
    resources :clients, module: :company

    get 'crm' => 'company/crm#index'
  end
end
