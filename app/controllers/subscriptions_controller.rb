class SubscriptionsController < ApplicationController
  before_action :confirm_actions, only: [:create, :update, :destroy]
  before_action :set_subscription, only: [:show, :edit, :update, :destroy, :cancel]

  def get_autodata_subscription
    record_id = params[:record_id]
    client_id = params[:client_id]

    record_client = RecordClient.find_by record_id: record_id, client_id: client_id

    record = Record.find(record_client.record_id)
    last_subscriptions_client = Subscription.where(record_client_id: record_client.id, is_active: true).order('finish_at').last
    
    # if last_subscriptions_client.present? and last_subscriptions_client.finish_at > Date.today
    if last_subscriptions_client.present?
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
      booking_date = "Сейчас время свободное"
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

  def create
    @subscription = Subscription.new(subscription_params)
    rc = RecordClient.eager_load(:record).find_by record_id: params[:record_id], client_id: params[:client_id]
    r = @current_record.find rc.record_id
    price = params[:price]
    note_recalculate = params[:note_recalculate]
    
    # amount = params[:amount].to_f

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
                 Date.today, @subscription.record_client_id).order('created_at DESC').first

    if discounts_record_client.present?
      @subscription.price = discounts_record_client.value
    end
    
    if price.present? and note_recalculate.present?
      @subscription.price = price
      @subscription.note = note_recalculate
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

    if (price.present? and !note_recalculate.present?) or (note_recalculate.present? and !price.present?)
      complited = false
      note = 'Чтобы указать свою цену, нужно заполнить поле Цены и Комментария'

    elsif !Client.exists? company_id: @current_company, id: params[:client_id]
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
      result = @subscription

    else
      complited = false
      note = "Абонемент не продан"
    end

    messege = {
      complited: complited, 
      note: note, 
      result: result,
      operation: operation,
    }

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

  def recalculation
    subscription_id = params[:id]
    price = params[:price]
    subscription_recalculation_note = params[:note]
    current_record_client = RecordClient.where record_id: @current_record


    if price === '' || price === nil
      complited = false
      note = 'Нужно указать сумму перерасчета'

    elsif subscription_recalculation_note == ''
      complited = false
      note = 'Нужно указать причину отмены в поле'

    elsif !(Subscription.exists? id: subscription_id, record_client_id: current_record_client)
      complited = false
      note = 'Нет такого абонемента'

    else
      s = Subscription.find subscription_id
      s.update_attributes(price: price, note: subscription_recalculation_note)
      complited = true
      note = 'Перерасчет произведен'
    end

    messege = {complited: complited, note: note}

    respond_to do |format|
      format.json { render json: messege }
    end    
  end

  def cancel
    subscription_id = params[:id]
    subscription_cancel_note = params[:note]
    current_record_client = RecordClient.where record_id: @current_record

    if !(Subscription.exists? id: subscription_id, record_client_id: current_record_client)
      complited = false
      note = 'Нет такого абонемента'

    elsif subscription_cancel_note == ''
      complited = false
      note = 'Нужно указать причину отмены в поле'

    else
      s = Subscription.find subscription_id
      s.update_attribute(:is_active, false)
      complited = true
      note = 'Отмена произведена'

      company_transactions = CompanyTransaction.where operation_id: s.operation_id, affiliate_id: @current_affiliates
      transactions = Transaction.where company_transaction_id: company_transactions

      transactions.each do |t|
        t.update_attribute(:is_active, false)
      end
    end

    messege = {complited: complited, note: note}

    respond_to do |format|
      format.json { render json: messege }
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
