json.extract! person, :id, :first_name, :last_name, :patronymic, :birthday, :phone_number, :sex, :created_at, :updated_at
json.url company_worker_url(person.company_id, person, format: :json)
