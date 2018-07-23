class HomeController < ApplicationController
  layout 'application'

  def index
  end

  def clients

    # @search_clients = params[:searchClients]
    @last_name_search = params[:lastNameClients]
    @first_name_search = params[:firstNameClients]
    @patronymic_search = params[:patronymicClients]

    if params[:record].present?
      record_id = params[:record]
      record = Record.find record_id
      record_clients = RecordClient.where record_id: record
      query_record = "AND id IN (#{record_clients.select(:client_id)})"
    # else
    #   query_record = ''
    end

    # if @last_name_search.present? and @first_name_search.present?
    #   if @last_name_search.size > 0
    #     last_name = "LOWER(last_name) LIKE LOWER('#{@last_name_search}%')"
    #   end

    #   if @first_name_search.size > 0
    #     first_name = "LOWER(first_name) LIKE LOWER('#{@first_name_search}%')"
    #   end
    # end

    # clients = Client.where("LOWER(last_name) LIKE LOWER('#{@search_clients[0]}%') 
    #     AND id IN (?)", record_clients.select(:client_id))

    # clients = Client.where("#{last_name} and #{first_name}")

    @people_company = Client.where(company: @current_company.id)
    @clients_company = @people_company.where("(role & #{Client::Role::CLIENT}) != 0")

    if params[:typeOfClients] == 'debtors'
      unpaid_subscriptions = Subscription.find_by_sql("
        SELECT subscriptions.id
        FROM subscriptions
        WHERE subscriptions.id NOT IN (
          SELECT operation_object_id
          FROM (
            SELECT operation_object_id, sum(amount) as total_amount
            FROM fin_operations
            WHERE operation_type = 1 AND is_active = true
            GROUP BY operation_object_id, operation_type)
            AS results
          WHERE total_amount >= price)
        AND subscriptions.is_active = true
        AND NOT price = 0
      ")
      
      @clients_company = @clients_company.where(id: 
        RecordClient.where(id: 
          Subscription.where(id: 
            unpaid_subscriptions).select('record_client_id')).
        select('client_id'))
    elsif params[:typeOfClients] == 'total'
      @clients_company = @people_company
    end


    clients = @clients_company.where("
      LOWER(last_name) LIKE LOWER('#{@last_name_search}%') 
      and LOWER(first_name) LIKE LOWER('#{@first_name_search}%') 
      and LOWER(patronymic) LIKE LOWER('#{@patronymic_search}%') 
    ").order(:last_name, :first_name, :patronymic)


    respond_to do |format|
      format.json { render json: clients, status: :ok }
    end
  end

  def search_result
    @search_request = params[:request]

    if @search_request.size == 1 and @search_request[0].size >= 1 or @search_request[1].size == 0
      @products = @total_clients_company.where("LOWER(last_name) LIKE LOWER('#{@search_request[0]}%')")
    elsif @search_request.size == 2 and @search_request[1].size >= 1 or @search_request[2].size == 0
      @products = @total_clients_company.where("LOWER(last_name) LIKE LOWER('%#{@search_request[0]}%') AND LOWER(first_name) LIKE LOWER('#{@search_request[1]}%')")
    elsif @search_request.size == 3 and @search_request[2].size >= 1
      @products = @total_clients_company.where("LOWER(last_name) LIKE LOWER('#{@search_request[0]}%') AND LOWER(first_name) LIKE LOWER('#{@search_request[1]}%') AND LOWER(patronymic) LIKE LOWER('#{@search_request[2]}%')")
    else
      @products = ""
    end

    @products = Client.where company_id: @current_company.id

    render layout: false
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
where rn = 1 and finish_at = '2018-06-30' and rc.is_active = true
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
                   Date.today, rc['id']).sum(:value)


      if price_correction.present?
        price_service = price_correction
      end

      subs = Subscription.new({
        start_at: start_at,
        finish_at: finish_at,
        visits: rc['total_visits'],
        record_client_id: rc['id'],
        price: price_service,
      })
      subs.save
      History.create({
        object_log: 'subscription', 
        object_id: subs.id, 
        type_history: 'auto_create', 
        note: 'Автоматическое создание абонемента по календарю', 
        user_id: current_user.id
      })
    end
    render plain: "#{rows.size} subscriptions were created"
  end

  def automatically_by_period
    yesterday = Date.today - 1
    today = Date.today

    sql = <<SQL
select rc.*, c.archive, r.total_visits, r.finished_at from (
  SELECT row_number() over(partition by record_client_id order by finish_at desc) rn, *
  FROM "subscriptions"
  WHERE is_active = true
) s inner join records_clients rc on s.record_client_id = rc.id
    inner join records r on rc.record_id = r.id
    inner join clients c on rc.client_id = c.id
where rn = 1 and finish_at = '2018-07-10' and rc.is_active = true
             and c.archive = false AND r.subscription_sale = 'automatically_by_period'
             AND (r.finished_at >= '2018-07-11' or r.finished_at IS NULL)
SQL

    rows = ActiveRecord::Base.connection.select_all(sql).to_hash

    rows.each do |rc|

      price_service = RecordService.where(record_id: rc['record_id']).sum(:money_for_abon).to_f
      price_correction = Discount.where(record_client_id: rc['id']).sum(:value)
      price = price_service + price_correction

      abon_period = Record.find(rc['record_id']).abon_period

      subs = Subscription.new({
        start_at: today,
        finish_at: today + abon_period,
        visits: rc['total_visits'],
        record_client_id: rc['id'],
        price: price,
      })
      subs.save
      History.create({
        object_log: 'subscription', 
        object_id: subs.id, 
        type_history: 'auto_create', 
        note: 'Автоматическое создание абонемента по завершения предыдущего', 
        user_id: current_user.id
      })
    end
    render plain: "#{rows.size} subscriptions were created"
  end
end
