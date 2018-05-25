class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:show, :edit, :update, :destroy]

  # GET /subscriptions
  # GET /subscriptions.json
  # def index
  #   @subscriptions = Subscription.all
  # end

  # GET /subscriptions/1
  # GET /subscriptions/1.json
  # def show
  # end

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

    @subscription.finish_at = @subscription.start_at + rc.record.abon_period.days
    @subscription.visits = rc.record.total_visits
    @subscription.price = RecordService.where(record_id: rc.record_id).sum(:money_for_abon)

    respond_to do |format|
      if @subscription.save
        format.html { redirect_to request.referer }
        format.json { render :show, status: :created, location: @subscription }
      else
        format.html { render :new }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /subscriptions/1
  # PATCH/PUT /subscriptions/1.json
  def update
    respond_to do |format|
      if @subscription.update(subscription_params)
        format.html { redirect_to @subscription, notice: 'Subscription was successfully updated.' }
        format.json { render :show, status: :ok, location: @subscription }
      else
        format.html { render :edit }
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
