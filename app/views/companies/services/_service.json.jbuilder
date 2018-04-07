json.extract! service, :id, :name, :created_at, :updated_at
json.url company_service_url(service.company, service, format: :json)
