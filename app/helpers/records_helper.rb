module RecordsHelper
  def client_title_in_select(client)
    title = "#{client.last_name} #{client.first_name}"
    title += " #{client.patronymic}" if client.patronymic
    title += " (#{client.birthday})" if client.birthday
    title
  end
  def debt_record(id)
    @records_clients = RecordClient.where(record_id: id)
    @subscriptions_clients = Subscription.where(record_client_id: @records_clients, is_active: true)
    @payments_subscriptions = FinOperation.where("
                is_active = true AND
                operation_type = 1 AND operation_object_id IN (?)", 
                @subscriptions_clients.select('id'),
                ).order("operation_date DESC")

    @payments_subscriptions.sum(:amount) - @subscriptions_clients.sum(:price)
  end
end
