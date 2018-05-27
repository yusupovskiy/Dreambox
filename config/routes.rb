Rails.application.routes.draw do
  # resources :subscriptions
  namespace :companies do
    get 'windows/show'
  end

  root 'home#index'

  devise_for :users, path: 'auth', controllers: {confirmations: 'confirmations'}
  get 'auth' => 'home#auth'
  get 'search_result' => 'home#search_result'

  resources :companies do
    resources :affiliates, module: :companies
    resources :records, module: :companies
    post 'clients/:id/archive/:archive_status' => 'companies/clients#archive', as: 'clients_archive'
    resources :clients, module: :companies
    resources :services, module: :companies
    resources :subscriptions, module: :companies

    resources :crm, controller: 'companies/crm', only: :index
  end
  # two primary keys
  delete 'records_services' => 'records_services#destroy'
  patch 'records_services' => 'records_services#update'
  resources :records_services
  resources :records_clients
  resources :windows, only: :show
  resources :discounts
end
