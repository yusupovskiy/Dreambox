Rails.application.routes.draw do
  namespace :companies do
    get 'windows/show'
  end

  root 'home#index'

  devise_for :users, path: 'auth', controllers: {confirmations: 'confirmations'}
  get 'auth' => 'home#auth'

  resources :companies do
    resources :affiliates, module: :companies
    resources :records, module: :companies
    post 'clients/:id/archive/:archive_status' => 'companies/clients#archive', as: 'clients_archive'
    resources :clients, module: :companies
    resources :services, module: :companies

    resources :crm, controller: 'companies/crm', only: :index
  end
  # two primary keys
  delete 'records_services' => 'records_services#destroy'
  resources 'records_services'
  resources :windows, only: :show
end
