Rails.application.routes.draw do
  namespace :companies do
    get 'windows/show'
  end

  root 'home#index'

  devise_for :users, path: 'auth', controllers: {confirmations: 'confirmations'}

  resources :companies do
    resources :affiliates, module: :companies
    resources :clients, module: :companies

    resources :crm, controller: 'companies/crm', only: :index
    resources :windows, controller: 'companies/windows', only: :show
  end
end
