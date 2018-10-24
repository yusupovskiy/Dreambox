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
  get 'get_records_clients' => 'records_clients#get_records_clients'

  resources :subscriptions do
    member do
      delete 'cancel'
    end
  end
  get 'get_autodata_subscription' => 'subscriptions#get_autodata_subscription'

  resources :workers do
    member do
      get 'role_employee'
      get 'role_client'
    end
  end
  get 'get_workers' => 'workers#get_workers'
  get 'get_works' => 'companies/works#get_works'
  
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
        # get 'doc_pko'
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

  resources :transactions do
      member do
        get 'doc_pko'
      end
    end
  get 'get_income' => 'transactions#get_income'
  post 'create_transaction' => 'transactions#create_transaction'
  get 'get_client_transactions' => 'transactions#get_client_transactions'
  get 'get_transactions' => 'transactions#get_transactions'
  delete 'cancel_transaction' => 'transactions#cancel_transaction'
  # get 'doc_pko' => 'transactions#doc_pko'
  
  get 'get_affiliates' => 'companies/affiliates#get_affiliates'
  
  resources :company_transactions
  
  resources :categories
  get 'get_categories' => 'categories#get_categories'
  get 'get_services' => 'categories#get_services'

  get 'get_works_affiliates' => 'works_salaries#get_works_affiliates'

  delete 'records_services_destroy' => 'works_salaries#destroy'

end
