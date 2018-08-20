json.extract! subscription, :id, :start_at, :finish_at, :visits, :is_active, :note, :created_at, :updated_at
json.url subscription_url(subscription, format: :json)
