Rails.application.routes.draw do
  # resources :subscriptions
  namespace :companies do
    get 'windows/show'
  end

  root 'home#index'
  get 'tbis' => 'home#add_subscriptions_automatically'

  devise_for :users, path: 'auth', controllers: {confirmations: 'confirmations'}
  get 'auth' => 'home#auth'
  get 'search_result' => 'home#search_result'

  resources :companies do
    resources :affiliates, module: :companies
    resources :records, module: :companies
    post 'clients/:id/archive/:archive_status' => 'companies/clients#archive', as: 'clients_archive'
    resources :clients, module: :companies 
    # do
    #   member do
    #     patch 'import'
    #   end
    # end
    post 'clients/import' => 'companies/clients#import'
    resources :services, module: :companies
    resources :subscriptions, module: :companies do
      member do
        patch 'cancel'
      end
    end
    resources :fin_operations, module: :companies
    resources :histories, module: :companies
  end
  # two primary keys
  delete 'records_services' => 'records_services#destroy'
  patch 'records_services' => 'records_services#update'
  resources :records_services
  resources :records_clients
  resources :windows, only: :show
  resources :discounts
end
