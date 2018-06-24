module CompaniesHelper
  def autodata_subscription(record_client)
    record = Record.find(record_client.record_id)
    last_subscriptions_client = Subscription.where(record_client_id: record_client.id, is_active: true).order('finish_at').last
    if last_subscriptions_client.present? and last_subscriptions_client.finish_at > Date.today
      message_start_date = "Подставилась дата на свободное число, после текущего и предстоящего абонементов"
      start_date = last_subscriptions_client.finish_at + 1.days
    else
      message_start_date = "Эта дата свободна"
      start_date = Date.today
    end
    if record.is_automatic == 'calendar_automatic'
      message_finish_date = "Так как в этой записи указаны абонементы по календарю, дата завершения абонемента подставляется на конец месяца"
      today = start_date
      date_of_last_day_of_previous_month = today - today.day.days
      finish_date = date_of_last_day_of_previous_month + Time.days_in_month(today.month).days
    else
      message_finish_date = "Дата, увеличенная на #{record.abon_period} дней с момента открытия"
      finish_date = start_date + record.abon_period.day
    end

    {start_date: start_date, message_start_date: message_start_date, finish_date: finish_date, message_finish_date: message_finish_date}
  end
  def corrent_role(role, beginning_line, line_end)
    total_role = ""
    if (role.to_i & Client::Role::COMPANY_OWNER) > 0
      total_role = total_role + beginning_line + "Руководитель" + line_end
    end
    if (role.to_i & Client::Role::STUFF) > 0
      total_role = total_role + beginning_line + "Сотрудник" + line_end
    end
    if (role.to_i & Client::Role::CLIENT) > 0
      total_role = total_role + beginning_line + "Клиент" + line_end
    end
    
    total_role.html_safe
  end
end
