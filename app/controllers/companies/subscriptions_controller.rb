class Companies::SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:show, :edit, :update, :destroy]

  # GET /subscriptions
  # GET /subscriptions.json
  def index
    affiliates = Affiliate.where(company_id: params[:company_id])
    records = Record.where(affiliate: affiliates)
    rc = RecordClient.where(record: records)
    @subscriptions = Subscription.where(record_client: rc)
  end

  # GET /subscriptions/1
  # GET /subscriptions/1.json
  def show
    @fin_operation = FinOperation.new
    record_client_subscription = RecordClient.find(@subscription.record_client_id)
    @client_subscription = Client.find(record_client_subscription.client_id)
    @record_client = Record.find(record_client_subscription.record_id)

    @fin_operations_subscription = FinOperation.where("
      operation_type = 1 AND operation_object_id IN (?)", 
      @subscription.id,
      ).order("operation_date DESC")
  end

  # GET /subscriptions/new
  # def new
  #   @subscription = Subscription.new
  # end

  # GET /subscriptions/1/edit
  def edit
  end

  # POST /subscriptions
  # POST /subscriptions.json
  def create
    @subscription = Subscription.new(subscription_params)
    rc = RecordClient.eager_load(:record).find @subscription.record_client_id

    if @subscription.finish_at.nil?
      @subscription.finish_at = @subscription.start_at + rc.record.abon_period.days
    end
    @subscription.visits = rc.record.total_visits
    @subscription.price = RecordService.where(record_id: rc.record_id).sum(:money_for_abon)

    respond_to do |format|
      no_subscriptions_in_that_range = rc.subscriptions
        .where('? between start_at and finish_at and ? between start_at and finish_at',
               @subscription.start_at, @subscription.finish_at)
        .count.zero?
      if no_subscriptions_in_that_range and @subscription.save
        # format.html { redirect_to params[:return_url] }
        format.html { redirect_to request.referer, notice: "Вы продали <a href=\"#{company_subscription_path(params[:company_id], @subscription.id)}\" class=\"link-style\">абонемент</a> на период от #{@subscription.start_at.strftime("%d %b %Y")} до #{@subscription.finish_at.strftime("%d %b %Y")}" }  # from records/:id
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

    @subscription.is_active = :false

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
