Rails.application.routes.draw do
  namespace :companies do
    get 'windows/show'
  end

  root 'home#index'

  get 'iairgmqqimuuoeexaspwkjykrtaocalendar' => 'home#add_subscriptions_automatically'
  get 'upewuadesutgqavgimmwvdwfizyfgwperiod' => 'home#automatically_by_period'

  devise_for :users, path: 'auth', controllers: {confirmations: 'confirmations'}

  get 'auth' => 'home#auth'
  get 'account' => 'home#account'

  get 'persons/profile'
  get 'persons/new_profile'
  post 'persons/role_person/:role_person' => 'persons#role_person', as: 'role_person'
  get 'company' => 'companies#company'

  resources :clients do
    member do
      # patch 'import'
      get 'role_employee'
      get 'role_client'
      # post 'add_field'
    end
  end
  post 'clients/:id/archive/:archive_status' => 'companies/clients#archive', as: 'clients_archive'
  get 'get_clients' => 'clients#get_clients'
  get 'add_field' => 'clients#add_field'
  get 'get_fields_client' => 'clients#get_fields_client'

  delete 'records_client_unpin' => 'records_clients#destroy'

  resources :records do
    member do
      get 'end_recording'
    end
  end
  get 'get_records' => 'records#get_records'
  get 'get_records_client' => 'records#get_records_client'
  get 'get_select_records_client' => 'records#get_select_records_client'
  get 'get_subs_client' => 'records#get_subs_client'

  resources :subscriptions do
    member do
      patch 'cancel'
    end
  end
  get 'get_autodata_subscription' => 'subscriptions#get_autodata_subscription'
  get 'get_subscriptions_client' => 'subscriptions#get_subscriptions_client'
  get 'get_subscriptions' => 'subscriptions#get_subscriptions'

  resources :companies do
    resources :affiliates, module: :companies
    resources :workers, module: :companies do
      member do
        get 'role_employee'
        get 'role_client'
      end
    end
    post 'clients/import' => 'companies/clients#import'
    resources :fin_operations, module: :companies do
      member do
        get 'doc_pko'
      end
    end
    resources :histories, module: :companies
    resources :works, module: :companies
    resources :salaries, module: :companies
    resources :services, module: :companies
  end
  
  # two primary keys
  delete 'records_services' => 'records_services#destroy'
  patch 'records_services' => 'records_services#update'
  resources :records_services
  resources :records_clients
  resources :windows, only: :show
  resources :discounts
  resources :works_salaries
  resources :info_blocks
  resources :field_templates
  resources :field_data

  resources :transactions
  get 'get_income' => 'transactions#get_income'
  post 'create_transaction' => 'transactions#create_transaction'
  get 'get_client_transactions' => 'transactions#get_client_transactions'
  delete 'cancel_transaction' => 'transactions#cancel_transaction'
  
  get 'get_affiliates' => 'companies/affiliates#get_affiliates'
  
  resources :company_transactions
  
  resources :categories
  get 'get_categories_income' => 'categories#get_categories_income'
  get 'get_categories_expense' => 'categories#get_categories_expense'

end
