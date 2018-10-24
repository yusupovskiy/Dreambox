module Companies::WorkersHelper
  def options_for_sexes
    options_for(Client.sexes, 'sex')
  end
  def info_sub(id)
    subscription = Subscription.find_by(id: id)
    if @records_client.exists?(id: subscription.record_client_id)
      records_client_sub = @records_client.find(subscription.record_client_id)
      records_sub = Record.find(records_client_sub.record_id).name
      payments_subscription = FinOperation.where(operation_type: 1, is_active: true, operation_object_id: subscription.id).sum(:amount)

      price_subscription = subscription.price - payments_subscription.to_f

     	"#{price_subscription} ₽ | #{records_sub} | по #{subscription.start_at.strftime("%d %B %Y")} 
     	до #{subscription.finish_at.strftime("%d %B %Y")}"
    else
      "Такого абонемента нет"
    end
  end
  def email_user( id)
    if id.present?
      email = User.find(id).email
      email.nil? ? '' : email
    end
  end
  def desc_content(id)
    records_clients = RecordClient.where(client_id: id)
    records = Record.where(id: records_clients.select('record_id'))
    records_service = RecordService.where(record_id: records.select('id'))
    service = Service.where(id: records_service.select('service_id'))
    content = ''

    if records_clients.present?
      service.each do |s|
        content = content + "- " + s.name
      end
    else
      content = 'Услуги не оказываются'
    end

    content
  end
  def monetary_indicator(id)
    @records_clients = RecordClient.where(client_id: id, record_id: @current_record)
    @subscriptions_clients = Subscription.where(record_client_id: @records_clients, is_active: true)
    @payments_subscriptions = FinOperation.where("
                is_active = true AND
                operation_type = 1 AND operation_object_id IN (?)", 
                @subscriptions_clients.select('id'),
                ).order("operation_date DESC")

    @payments_subscriptions.sum(:amount) - @subscriptions_clients.sum(:price)
  end
  def name_tab_workers(i)
    if i == 0
      "Сотрудники"
    else
      "Без названия"
    end
  end
  def info_tab(i)
    if i == 0
      "Все сотрудники компании"
    else
      "Без названия"
    end
  end
end
