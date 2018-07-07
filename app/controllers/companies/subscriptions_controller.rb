class Companies::SubscriptionsController < ApplicationController
  before_action :set_people
  before_action :set_company
  before_action :set_access
  before_action :set_affiliate
  before_action :confirm_actions, only: [:create, :update, :destroy]
  before_action :set_subscription, only: [:show, :edit, :update, :destroy, :cancel]

  # GET /subscriptions
  # GET /subscriptions.json
  def index
    affiliates = Affiliate.where(company_id: @current_company.id)
    records = Record.where(affiliate: affiliates)
    rc = RecordClient.where(record: records)
    @subscriptions = Subscription.where(record_client: rc)
  end

  # GET /subscriptions/1
  # GET /subscriptions/1.json
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

  # GET /subscriptions/new
  # def new
  #   @subscription = Subscription.new
  # end

  # GET /subscriptions/1/edit
  # def edit
  # end

  # POST /subscriptions
  # POST /subscriptions.json
  def create
    @subscription = Subscription.new(subscription_params)
    rc = RecordClient.eager_load(:record).find @subscription.record_client_id
    r = @current_record.find rc.record_id
    amount = params[:subscription][:amount].to_f
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

    @subscription.price = @subscription.price + discounts_record_client.sum(:value)

    respond_to do |format|
      no_subscriptions_in_that_range = rc.subscriptions
        .where('(? between start_at and finish_at or ? between start_at and finish_at) and is_active = true',
               @subscription.start_at, @subscription.finish_at)
        .count.zero?
      has_record_expired = Record.where("id = ? AND finished_at > ?", rc.record_id, Date.today).count.zero?
      price_services = RecordService.where(record_id: 4)
      in_archive_whether_client = Client.where(id: rc.client_id, archive: false).count.zero?

      unless @subscription.price.to_i > 0
        return redirect_to request.referer, 
        notice: "<hr class=\"status-complet not-completed\" />Стоимость абонемента не может 
        быть ниже или равное нулю"
      end
      unless RecordClient.exists? record_id: @current_record, id: @subscription.record_client_id, client_id: rc.client_id
        return redirect_to request.referer, 
        notice: "<hr class=\"status-complet not-completed\" />У клиента нет такой записи"
      end

      if has_record_expired
        format.html { redirect_to request.referer, notice: "<hr class=\"status-complet not-completed\" />В завершенной записи нельзя продавать абонементы" }  # from records/:id
        format.json { render :show, status: :created, location: @subscription }
      elsif price_services.count.zero? or price_services.sum(:money_for_abon) == 0
        format.html { redirect_to request.referer, notice: "<hr class=\"status-complet not-completed\" />Перед продажей абонемента необходимо в записи добавить услугу, либо указать стоимость услуги больше нуля" }  # from records/:id
        format.json { render :show, status: :created, location: @subscription }
      elsif in_archive_whether_client
        format.html { redirect_to request.referer, notice: "<hr class=\"status-complet not-completed\" />Данному клиенту нельзя продавать абонементы, так как он в архиве" }  # from records/:id
        format.json { render :show, status: :created, location: @subscription }
      elsif rc.is_active == false
        format.html { redirect_to request.referer, notice: "<hr class=\"status-complet not-completed\" />Невозможно продать абонемент, так как клиент отписан от данной записи" }  # from records/:id
        format.json { render :show, status: :created, location: @subscription }
      elsif no_subscriptions_in_that_range and @subscription.save
        if amount <= 0
          amount_notice = ""
        elsif amount > @subscription.price
          amount_notice = "<br /><br />- Оплата не произведена, так как не может превышать стоимость абонемента"
        else
            payment = FinOperation.new(
            amount: amount, 
            affiliate_id: r.affiliate_id, 
            operation_type: 1, 
            operation_object_id: @subscription.id, 
            operation_date: @subscription.start_at, 
            description: "Оплата абонемента на период 
            от #{@subscription.start_at.strftime("%d %B %Y")} 
            до #{@subscription.finish_at.strftime("%d %B %Y")}", 
            user_id: current_user.id
          )
          payment.save
          amount_notice = "<br /><br />Финансовая операция <a href=\"#{company_fin_operation_path(@current_company.id, payment.id)}\" class=\"link-style\" style=\"text-transform: lowercase;\">#{t('operation_type.payment_subscription')}</a> на сумму <span class=\"amount\">#{amount} ₽</span> произведена"
        end
        # format.html { redirect_to params[:return_url] }
        format.html { redirect_to request.referer, notice: "<hr class=\"status-complet completed\" />Вы продали <a href=\"#{company_subscription_path(@current_company.id, @subscription.id)}\" class=\"link-style\">абонемент</a> на период от #{@subscription.start_at.strftime("%d %b %Y")} до #{@subscription.finish_at.strftime("%d %b %Y")}" + amount_notice }  # from records/:id
        format.json { render :show, status: :created, location: @subscription } 
      else
        notice = no_subscriptions_in_that_range ? nil : t(:reserved_range_for_subscription)
        format.html { redirect_to request.referer, notice: notice }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /subscriptions/1
  # PATCH/PUT /subscriptions/1.json 
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

  # DELETE /subscriptions/1
  # DELETE /subscriptions/1.json
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
