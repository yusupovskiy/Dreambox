class SubscriptionsController < ApplicationController
  before_action :confirm_actions, only: [:create, :update, :destroy]
  before_action :set_subscription, only: [:show, :edit, :update, :destroy, :cancel]

  def get_autodata_subscription
    record_id = params[:record_id]
    client_id = params[:client_id]

    record_client = RecordClient.find_by record_id: record_id, client_id: client_id

    record = Record.find(record_client.record_id)
    last_subscriptions_client = Subscription.where(record_client_id: record_client.id, is_active: true).order('finish_at').last
    
    if last_subscriptions_client.present? and last_subscriptions_client.finish_at > Date.today
      message_start_date = "Подставилась дата на свободное число, после текущего и предстоящего абонементов"
      start_date = last_subscriptions_client.finish_at + 1.days
    else
      message_start_date = "Эта дата свободна"
      start_date = Date.today
    end
    if record.subscription_sale == 'by_calendar' or record.subscription_sale == 'automatically_by_calendar'
      message_finish_date = "Так как в этой записи указаны абонементы по календарю, дата завершения абонемента подставляется на конец месяца"
      today = start_date
      date_of_last_day_of_previous_month = today - today.day.days
      finish_date = date_of_last_day_of_previous_month + Time.days_in_month(today.month).days
    else
      message_finish_date = "Дата, увеличенная на #{record.abon_period} дней с момента открытия"
      finish_date = start_date + record.abon_period.day
    end

    s = Subscription.order('finish_at DESC').find_by(record_client_id: record_client.id)

    if s.present?
      booking_date = "Бронь до #{s.finish_at.strftime("%d %B %Y")}"
    else 
      booking_date = "Сейчас свободное время"
    end

    date = {
      start_date: start_date, 
      message_start_date: message_start_date, 
      finish_date: finish_date, 
      message_finish_date: message_finish_date,
      booking_date: booking_date
    }

    respond_to do |format|
      format.json { render json: date, status: :ok }
    end
  end


  def get_subscriptions_client
    client_id = params[:client_id]
    operation_id = params[:operation_id].to_i
    operation = operation_id > 0 ? "AND s.operation_id = #{operation_id}" : ''

    if Client.exists? id: client_id, company_id: @current_company

      records_client = RecordClient.where(client_id: client_id, record_id: @current_record)

      if Subscription.exists? record_client_id: records_client
        affiliates_id = @current_affiliates.ids.join(", ")
        records_client = records_client.ids.join(", ")

        unpaid_subscriptions = Subscription.find_by_sql("
          SELECT s.*, coalesce(SUM(t.amount), 0) AS total_amount, r.name
          FROM subscriptions AS s
            LEFT JOIN ( SELECT records_clients.*
                        FROM records_clients
              ) AS rc
              ON s.record_client_id = rc.id
            LEFT JOIN records AS r
              ON rc.record_id = r.id
            LEFT JOIN ( SELECT company_transactions.*
                        FROM company_transactions
                        WHERE company_transactions.affiliate_id IN (#{affiliates_id})
              ) AS ct
              ON s.operation_id = ct.operation_id
            LEFT JOIN ( SELECT SUM(t1.amount) AS amount, t1.company_transaction_id
                        FROM transactions AS t1
                        WHERE (t1.is_active IS NULL or t1.is_active = true)
                        GROUP BY t1.company_transaction_id
              ) AS t 
              ON ct.id = t.company_transaction_id
                      
          WHERE (s.is_active IS NULL OR s.is_active = true)
            AND r.affiliate_id IN (#{affiliates_id})
            AND record_client_id IN (#{records_client}) #{operation}
          GROUP BY s.id, r.name
        ")
      end
    end

    respond_to do |format|
      format.json { render json: unpaid_subscriptions, status: :ok }
    end
  end

  def index
    affiliates = Affiliate.where(company_id: @current_company.id)
    records = Record.where(affiliate: affiliates)
    rc = RecordClient.where(record: records)
    @subscriptions = Subscription.where(record_client: rc)
  end

  def show
    @fin_operation = FinOperation.new
    @history = History.new
    record_client_subscription = RecordClient.find(@subscription.record_client_id)
    @client_subscription = Client.find(record_client_subscription.client_id)
    @record_client = Record.find(record_client_subscription.record_id)

    @fin_operations_subscription = FinOperation.where("
      operation_type = 1 AND operation_object_id IN (?)", 
      @subscription.id,
      ).order("operation_date DESC")

    @history_subscription = History.where("
      object_log = 'subscription' AND object_id IN (?)", 
      @subscription.id,
      ).order("created_at DESC")
  end

  def create
    @subscription = Subscription.new(subscription_params)

    rc = RecordClient.eager_load(:record).find_by record_id: params[:record_id], client_id: params[:client_id]
    r = @current_record.find rc.record_id
    
    amount = params[:amount].to_f

    @subscription.record_client_id = rc.id

    operation = Operation.create(client_id: rc.client_id)
    @subscription.operation_id = operation.id

    # conversion_amount = params[:subscription][:conversion_amount].to_f
    # note = params[:subscription][:note]

    # if conversion_amount > 0 note == ""
    #   @subscription.price = conversion_amount
    #   conversion_amount_notice = "<br /><br />Вы сделали перерасчет, стоимость абонемента теперь <span class=\"amount\">#{@subscription.price} ₽</span>"
    # else
    #   conversion_amount_notice = ""
    # end

    if @subscription.finish_at.nil?
      @subscription.finish_at = @subscription.start_at + rc.record.abon_period.days
    end
    @subscription.visits = rc.record.total_visits
    @subscription.price = RecordService.where(record_id: rc.record_id).sum(:money_for_abon)

    discounts_record_client = Discount.where('
                 (? between start_at and finish_at) and 
                 is_active = true and 
                 record_client_id = ?', 
                 Date.today, @subscription.record_client_id)

    if discounts_record_client.present?
      @subscription.price = discounts_record_client.sum(:value)
    end
    
    no_subscriptions_in_that_range = rc.subscriptions
      .where('(? between start_at and finish_at or ? between start_at and finish_at) and is_active = true',
             @subscription.start_at, @subscription.finish_at)
      .count.zero?

    completed_records = Record.where("finished_at < ?", Date.today)
    no_completed_records = Record.where.not(id: completed_records)
    has_record_expired = no_completed_records.exists? id: rc.record_id

    price_services = RecordService.where(record_id: rc.record_id)
    in_archive_whether_client = Client.where(id: rc.client_id, archive: false).count.zero?

    #   elsif no_subscriptions_in_that_range and @subscription.save
    #     if amount <= 0
    #       amount_notice = ""
    #     elsif amount > @subscription.price
    #       amount_notice = "<br /><br />- Оплата не произведена, так как не может превышать стоимость абонемента"
    #     else
    #         payment = FinOperation.new(
    #         amount: amount, 
    #         affiliate_id: r.affiliate_id, 
    #         operation_type: 1, 
    #         operation_object_id: @subscription.id, 
    #         operation_date: @subscription.start_at, 
    #         description: "Оплата абонемента на период 
    #         от #{@subscription.start_at.strftime("%d %B %Y")} 
    #         до #{@subscription.finish_at.strftime("%d %B %Y")}", 
    #         user_id: current_user.id
    #       )
    #       payment.save
    #       amount_notice = "<br /><br />Финансовая операция <a href=\"#{company_fin_operation_path(@current_company.id, payment.id)}\" class=\"link-style\" style=\"text-transform: lowercase;\">#{t('operation_type.payment_subscription')}</a> на сумму <span class=\"amount\">#{amount} ₽</span> произведена"
    #     end

    if !Client.exists? company_id: @current_company, id: params[:client_id]
      complited = false
      note = 'Нет такого клиента'

    elsif !@current_record.exists? id: params[:record_id]
      complited = false
      note = 'Нет такой записи'

    elsif (@current_company.record_limit - @current_clients_company.count) <= 0
      messege = {complited: false, note: 'Вы достигли лимита по тарифу'}

    elsif !RecordClient.exists? record_id: @current_record, id: @subscription.record_client_id, client_id: rc.client_id
      complited = false
      note = 'У клиента нет такой записи'

    elsif in_archive_whether_client
      complited = false
      note = 'Продажа отменена, так как клиент находится в архиве'

    elsif !has_record_expired
      complited = false
      note = 'В завершенной записи нельзя продавать абонементы'

    elsif !rc.is_active
      complited = false
      note = 'Невозможно продать абонемент, так как клиент отписан от данной записи'
      
    # elsif price_services.count.zero? or price_services.sum(:money_for_abon) <= 0
    #   complited = false
    #   note = 'Перед продажей абонемента необходимо в записи добавить услугу, либо указать стоимость услуги больше нуля'

    elsif @subscription.price.to_i < 0
      complited = false
      note = 'Стоимость абонемента не может быть ниже нуля'

    elsif !no_subscriptions_in_that_range
      complited = false
      note = t(:reserved_range_for_subscription)

    elsif @subscription.save
      complited = true
      note = "Продан абонемент на период от #{@subscription.start_at.strftime("%d %b %Y")} 
                до #{@subscription.finish_at.strftime("%d %b %Y")}"

    else
      complited = false
      note = "Абонемент не продан"
    end

    messege = {complited: complited, note: note}

    respond_to do |format|
      format.json { render json: messege }
    end
  end

  def update

    @subscription = Subscription.new(subscription_params)

    respond_to do |format|
      if @subscription.update(subscription_params)
        format.html { redirect_to @subscription, notice: 'Subscription was successfully updated.' }
        format.html { redirect_to request.referer }  # from records/:id
        format.json { render :show, status: :ok, location: @subscription }
      else
        format.html { render :edit }
        format.html { redirect_to request.referer, notice: notice }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @subscription.destroy
    respond_to do |format|
      format.html { redirect_to subscriptions_url, notice: 'Subscription was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def cancel
    @params_note = Subscription.new(params.require(:subscription).permit(:note))

    respond_to do |format|    
      if @params_note.note != '' and @subscription.is_active == true
        @subscription.note = @params_note.note + ' | ' + Date.today.strftime("%d %b %Y")
        @subscription.is_active = @subscription.is_active == true ? false : true 
        @subscription.save!
        format.html { redirect_to request.referer, notice: 'Отмена произведена' }
        format.json { render :show, status: :ok, location: @subscription }
      else
        format.html { redirect_to request.referer, notice: 'Отмена не удалась' }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subscription
      @subscription = Subscription.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def subscription_params
      params.require(:subscription).permit(:start_at, :finish_at, :visits, :is_active, :note, :record_client_id)
    end
end
