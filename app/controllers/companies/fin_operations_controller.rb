class Companies::FinOperationsController < ApplicationController
  before_action :confirm_actions, only: [:create, :update, :destroy]
  before_action :fin_operation_params, only: [:create, :update, :destroy]

  def index
    affiliates = Affiliate.where(company_id: @current_company.id)
    records = Record.where(affiliate: affiliates)
    rc = RecordClient.where(record: records)
    subscriptions = Subscription.where(record_client: rc)

    @fin_operations = FinOperation.where("(
      (operation_type = 1 AND operation_object_id IN (?)) OR 
      (operation_type = 0 AND operation_object_id IN (?)) AND
      affiliate_id IN (?))", 
      subscriptions.all.select('id'), 
      Client.where(company_id: @current_company.id).select('id'),
      @current_affiliate,
      ).order("operation_date DESC")

    if @fin_operations.present?
      if params[:start_date].nil?
        @start_date = @fin_operations.last.operation_date
      else
        @start_date = params[:start_date].nil? ? '' : params[:start_date]
      end

      if params[:finish_date].nil?
        @finish_date = @fin_operations.first.operation_date
      else
        @finish_date = params[:finish_date].nil? ? '' : params[:finish_date]
      end
      
      @fin_operations = FinOperation.where("( 
        operation_date >= '#{@start_date}' and operation_date <= '#{@finish_date}' AND
        (operation_type = 1 AND operation_object_id IN (?)) OR 
        (operation_type = 0 AND operation_object_id IN (?)) AND
        affiliate_id IN (?))", 
        subscriptions.all.select('id'), 
        Client.where(company_id: @current_company.id).select('id'),
        @current_affiliate,
        ).order("operation_date DESC")
    end


  end

  def show
    @fin_operation = FinOperation.find(params[:id])
    @responsible = User.find(@fin_operation.user_id)
    @affiliate = Affiliate.find(@fin_operation.affiliate_id)

    if @fin_operation.operation_type == 'payment_other'
      @subscription = Client.find(@fin_operation.operation_object_id)
    elsif @fin_operation.operation_type == 'payment_subscription'
      @subscription = Subscription.find(@fin_operation.operation_object_id)
      record_subscription = RecordClient.find(@subscription.record_client_id)
      @client_subscription = Client.find(record_subscription.client_id)
    end


    @history = History.new
    @history_subscription = History.where("
      object_log = 'fin_operation' AND object_id IN (?)",
                                          @fin_operation.id,
      ).order("created_at DESC")
  end

  # def new
  #   @fin_operation = FinOperation.new
  #   @affiliates = Affiliate.where(company_id: @current_company.id)
  # end

  def create
    @fin_operation = FinOperation.new(fin_operation_params)
    @fin_operation.user_id = current_user.id

    # сделать проверку, ответственнен ли сотрудник за указанный филиал
    # при реализации функционала расходов, сделать чтобы номер шол отдельно от них, только за оплаты
    
    if @fin_operation.amount.to_i <= 0
      redirect_to request.referer, notice: "<hr class=\"status-complet not-completed\" />Операция не произведена, необходимо указать сумму больше <span class=\"amount\">0.0 ₽</span>"      
    elsif @fin_operation.operation_type == 'payment_other'
      if @fin_operation.save
        redirect_to request.referer, notice: "<hr class=\"status-complet completed\" />Финансовая операция <a href=\"#{company_fin_operation_path(@current_company.id, @fin_operation.id)}\" class=\"link-style\" style=\"text-transform: lowercase;\">#{t('operation_type.' + @fin_operation.operation_type)}</a> на сумму <span class=\"amount\">#{@fin_operation.amount} ₽</span> произведена"
      else
        render :new
      end
    elsif @fin_operation.operation_type == 'payment_subscription'
      subscription = Subscription.find(@fin_operation.operation_object_id)
      record_client = RecordClient.find(subscription.record_client_id)
      record = Record.find(record_client.record_id)
      @fin_operation.affiliate_id = record.affiliate_id

      if FinOperation.exists?(affiliate_id: @fin_operation.affiliate_id)
        fin_operation = FinOperation.where(affiliate_id: @fin_operation.affiliate_id).last
        @fin_operation.operation_number = 1 + fin_operation.operation_number.to_i
      else
        @fin_operation.operation_number = 1
      end

      subscription = Subscription.find(@fin_operation.operation_object_id)
      subscription_payments = FinOperation.where("is_active = true AND operation_type = 1 AND operation_object_id IN (?)", subscription.id).sum(:amount)
      amount_payment = subscription.price - subscription_payments
      @fin_operation.description = "Оплата абонемента на период от #{subscription.start_at.strftime("%d %B %Y")} до #{subscription.finish_at.strftime("%d %B %Y")}"

      if @fin_operation.amount > amount_payment
        redirect_to request.referer, notice: "<hr class=\"status-complet not-completed\" />Вы внесли сумму больше чем необходимо заплатить за абонемент. Вам необходимо оплатить <span class=\"amount\">#{subscription.price - subscription_payments} ₽</span> вместо <span class=\"amount\">#{@fin_operation.amount} ₽</span>"
      elsif @fin_operation.save
        redirect_to request.referer, notice: "<hr class=\"status-complet completed\" />Финансовая операция <a href=\"#{company_fin_operation_path(@current_company.id, @fin_operation.id)}\" class=\"link-style\" style=\"text-transform: lowercase;\">#{t('operation_type.' + @fin_operation.operation_type)}</a> на сумму <span class=\"amount\">#{@fin_operation.amount} ₽</span> произведена"
      else
        render :new
      end
    end

  end

  def doc_pko
    @fin_operation = FinOperation.find(params[:id])

    if @fin_operation.operation_type == 'payment_other'
      @client_subscription = Client.find(@fin_operation.operation_object_id)
    elsif @fin_operation.operation_type == 'payment_subscription'
      @subscription = Subscription.find(@fin_operation.operation_object_id)
      record_subscription = RecordClient.find(@subscription.record_client_id)
      @client_subscription = Client.find(record_subscription.client_id)
    end

    render :template => 'companies/fin_operations/doc_pko',layout: false    
  end

  private
    def fin_operation_params
      params.require(:fin_operation).permit(:amount, :operation_date, :operation_type, :operation_object_id, :is_active, :description, :description_cancellation, :affiliate_id)
    end
end
