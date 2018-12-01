class HomeController < ApplicationController
  layout 'application'

  def index
    return redirect_to clients_path
  end

  def account
    @email = params[:request]
    @user_accounts = User.find_by(email: @email)

    render layout: false
  end

  def add_subscriptions_automatically
    today = Date.today
    date_of_last_day_of_previous_month = today - today.day.days

    sql = <<SQL
select rc.*, c.archive, r.total_visits, r.finished_at from (
  SELECT row_number() over(partition by record_client_id order by finish_at desc) rn, *
  FROM "subscriptions"
  WHERE is_active = true
) s inner join records_clients rc on s.record_client_id = rc.id
    inner join records r on rc.record_id = r.id
    inner join clients c on rc.client_id = c.id
where rn = 1 and finish_at = '#{date_of_last_day_of_previous_month}' and rc.is_active = true
             and c.archive = false AND r.subscription_sale = 'automatically_by_calendar'
             AND (r.finished_at > '#{today}' or r.finished_at IS NULL)
SQL

    start_at = date_of_last_day_of_previous_month + 1.day
    finish_at = date_of_last_day_of_previous_month + Time.days_in_month(today.month).days
    rows = ActiveRecord::Base.connection.select_all(sql).to_hash

    rows.each do |rc|
      price_service = RecordService.where(record_id: rc['record_id']).sum(:money_for_abon).to_f
      price_correction = Discount.where('
                   (? between start_at and finish_at) and 
                   is_active = true and 
                   record_client_id = ?', 
                   Date.today, rc['id']).order('created_at DESC').first

      if price_correction.present?
        price_service = price_correction.value
      end

      operation = Operation.create client_id: rc['client_id']

      subs = Subscription.new({
        start_at: start_at,
        finish_at: finish_at,
        visits: rc['total_visits'],
        record_client_id: rc['id'],
        price: price_service,
        operation_id: operation.id,
      })
      subs.save
      # History.create({
      #   object_log: 'subscription', 
      #   object_id: subs.id, 
      #   type_history: 'auto_create', 
      #   note: 'Автоматическое создание абонемента по календарю', 
      #   user_id: current_user.id
      # })
    end
    render plain: "#{rows.size} subscriptions were created"
  end

  def automatically_by_period
    today = Date.today
    yesterday = today - 1

    sql = <<SQL
select rc.*, c.archive, r.total_visits, r.finished_at from (
  SELECT row_number() over(partition by record_client_id order by finish_at desc) rn, *
  FROM "subscriptions"
  WHERE is_active = true
) s inner join records_clients rc on s.record_client_id = rc.id
    inner join records r on rc.record_id = r.id
    inner join clients c on rc.client_id = c.id
where rn = 1 and finish_at = '#{yesterday}' and rc.is_active = true
             and c.archive = false AND r.subscription_sale = 'automatically_by_period'
             AND (r.finished_at >= '2018-07-11' or r.finished_at IS NULL)
SQL

    rows = ActiveRecord::Base.connection.select_all(sql).to_hash

    rows.each do |rc|
      price_service = RecordService.where(record_id: rc['record_id']).sum(:money_for_abon).to_f
      price_correction = Discount.where('
                   (? between start_at and finish_at) and 
                   is_active = true and 
                   record_client_id = ?', 
                   Date.today, rc['id']).order('created_at DESC').first

      if price_correction.present?
        price_service = price_correction.value
      end

      abon_period = Record.find(rc['record_id']).abon_period

      operation = Operation.create client_id: rc['client_id']

      subs = Subscription.new({
        start_at: today,
        finish_at: today + abon_period,
        visits: rc['total_visits'],
        record_client_id: rc['id'],
        price: price_service,
        operation_id: operation.id,
      })
      subs.save
      # History.create({
      #   object_log: 'subscription', 
      #   object_id: subs.id, 
      #   type_history: 'auto_create', 
      #   note: 'Автоматическое создание абонемента по завершения предыдущего', 
      #   user_id: current_user.id
      # })
    end
    render plain: "#{rows.size} subscriptions were created"
  end
end
