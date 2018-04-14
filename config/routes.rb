Rails.application.routes.draw do
  namespace :companies do
    get 'windows/show'
  end

  root 'home#index'

  devise_for :users, path: 'auth', controllers: {confirmations: 'confirmations'}
  get 'auth' => 'home#auth'

  resources :companies do
    resources :affiliates, module: :companies
    resources :clients, module: :companies
    resources :services, module: :companies

    resources :crm, controller: 'companies/crm', only: :index
  end
  resources :windows, only: :show
end
