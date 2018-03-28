json.extract! client, :id, :first_name, :last_name, :patronymic, :birthday, :created_at, :updated_at
json.url company_client_url(client.company_id, client, format: :json)
