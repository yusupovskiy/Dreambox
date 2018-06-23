class Companies::ClientsController < ApplicationController
  before_action :ensure_current_user, :ensure_company_owner_role, only: [:index, :new, :edit, :update, :destroy]
  before_action :set_client, only: [:show, :edit, :update, :destroy, :archive]
  before_action :ensure_user_has_company
  before_action :set_s3_direct_post, only: [:new, :edit]

  # GET /clients
  # GET /clients.json
  def index
    @clients = Client.where(company: params[:company_id])
    @total_clients = @clients.size
    @no_archive_clients = @clients.where(archive: false)
    @archive_clients = @clients.where(archive: true)
    @current_clients = @no_archive_clients.where(id: RecordClient.where(is_active: :true).select('client_id'))

    @debt_clients = @clients.where(
      id: RecordClient.where(
        id: Subscription.select('record_client_id')

      ).select('client_id'))

    # @subscription_payments = FinOperation.where(operation_type: 1, is_active: true).
    #   group("operation_object_id, operation_type").
    #   select("operation_object_id, sum(amount) as amount").
    #   order("operation_object_id")


    unpaid_subscriptions = Subscription.find_by_sql("
      SELECT subscriptions.id
      FROM subscriptions
      WHERE subscriptions.id NOT IN 
      (SELECT operation_object_id
            FROM (
             SELECT operation_object_id, sum(amount) as total_amount
             FROM fin_operations
             WHERE operation_type = 1 AND is_active = true
             GROUP BY operation_object_id, operation_type
            ) AS results
      WHERE total_amount >= price) AND subscriptions.is_active = true")
    @clients_debtors = @clients.where(id: RecordClient.where(id: Subscription.where(id: unpaid_subscriptions).select('record_client_id')).select('client_id'))

  end

  # GET /clients/1
  # GET /clients/1.json
  def show
    affiliates = Affiliate.where(company_id: params[:company_id])
    @records = Record.where(affiliate: affiliates)
    @records_clients = RecordClient.where(record_id: @records)
    @records_client = RecordClient.where(client_id: params[:id])

    @no_records_client = @records.where.not(id: @records_clients.where(client_id: @client.id, is_active: :true).select('record_id'))


    @discount = Discount.new
    @discounts = Discount.where(record_client: @records_client)

    @subscription = Subscription.new
    @fin_operation = FinOperation.new

    @clients = Client.where(archive: false, company_id: @current_company.id)

    subscriptions_client = Subscription.where(record_client: @records_client)
    @fin_operations_client = FinOperation.where("
      (operation_type = 1 AND operation_object_id IN (?)) OR 
      (operation_type = 0 AND operation_object_id = (?))", 
      subscriptions_client.all.select('id'), 
      @client.id,
      ).order("operation_date DESC")

    @payments_subscriptions = FinOperation.where(" is_active = true AND
                operation_type = 1 AND operation_object_id IN (?)", 
                subscriptions_client.where(is_active: true).select('id'),
                ).order("operation_date DESC")
    @debt_for_services =  subscriptions_client.where(is_active: true).sum(:price) - @payments_subscriptions.sum(:amount)
  end

  # GET /clients/new
  def new
    @client = Client.new company_id: params[:company_id]
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients
  # POST /clients.json
  def create
    prms = client_params
    @client = Client.new(prms)
    if email = params[:email]
      # TODO: create account (using transaction)
    end

    respond_to do |format|
      if @client.save
        format.html { redirect_to [@client.company, @client], notice: t('client.created') }
        format.json { render :show, status: :created }
      else
        format.html { ensure_current_user; set_s3_direct_post; render :new }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /clients/1
  # PATCH/PUT /clients/1.json
  def update
    respond_to do |format|
      if @client.update(client_params)
        format.html { redirect_to [@client.company, @client], notice: t('client.updated') }
        format.json { render :show, status: :ok, location: @client }
      else
        format.html { render :edit }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clients/1
  # DELETE /clients/1.json
  def destroy
    @client.destroy
    respond_to do |format|
      format.html { redirect_to company_clients_url, notice: t('client.destroyed') }
      format.json { head :no_content }
    end
  end

  def archive
    @client.archive = params[:archive_status] == '1'
    @client.save!
    respond_to do |format|
      format.html { redirect_to company_client_path(params[:company_id], params[:id]) }
      format.json { render :show, status: :ok, location: @client }
    end
  end

  def import
    text = params[:text]
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def client_params
      res = params.require(:client)
          .permit(:first_name, :last_name, :patronymic, :birthday, :phone_number, :sex, :avatar)
          .merge(company_id: params[:company_id])
      res[:avatar] = nil if params[:client][:avatar].blank?
      res
    end
    def set_s3_direct_post
      args = {
          key: "images/#{SecureRandom.uuid}/${filename}",
          success_action_status: '201',
          acl: 'public-read'
      }
      @s3_direct_post = S3_BUCKET.presigned_post(args)
    end
end
