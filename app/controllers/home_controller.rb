class HomeController < ApplicationController
  layout 'application'

  def index
    # TODO: remember the last used company instead of choose the first one
    @current_company = current_user.companies.first
    $current_company = @current_company
    # NotificationMailer.welcome.deliver_later
  end

  def search_result
    @search_request = params[:request]
    if @search_request.size == 1 and @search_request[0].size >= 1 or @search_request[1].size == 0
      @products = Client.where("LOWER(last_name) LIKE LOWER('#{@search_request[0]}%')")
    elsif @search_request.size == 2 and @search_request[1].size >= 1 or @search_request[2].size == 0
      @products = Client.where("LOWER(last_name) LIKE LOWER('%#{@search_request[0]}%') AND LOWER(first_name) LIKE LOWER('#{@search_request[1]}%')")
    elsif @search_request.size == 3 and @search_request[2].size >= 1
      @products = Client.where("LOWER(last_name) LIKE LOWER('#{@search_request[0]}%') AND LOWER(first_name) LIKE LOWER('#{@search_request[1]}%') AND LOWER(patronymic) LIKE LOWER('#{@search_request[2]}%')")
    else
      @products = ""
    end

    render layout: false
  end

  def add_subscriptions_automatically
    today = Date.today
    date_of_last_day_of_previous_month = today - today.day.days
    sql = <<SQL
select rc.*, r.total_visits from (
  SELECT row_number() over(partition by record_client_id order by finish_at desc) rn, *
  FROM "subscriptions"
) s inner join records_clients rc on s.record_client_id = rc.id
    inner join records r on rc.record_id = r.id
where rn = 1 and finish_at = '#{date_of_last_day_of_previous_month}'
SQL

    start_at = date_of_last_day_of_previous_month + 1.day
    finish_at = date_of_last_day_of_previous_month + Time.days_in_month(today.month).days
    rows = ActiveRecord::Base.connection.select_all(sql).to_hash
    rows.each do |rc|
      Subscription.create!({
        start_at: start_at,
        finish_at: finish_at,
        visits: rc['total_visits'],
        record_client_id: rc['id'],
      })
    end
    render plain: "#{rows.size} subscriptions were created"
  end
end
