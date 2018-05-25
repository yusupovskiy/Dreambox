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
    @no_archive_clients = Client.where(company: params[:company_id], archive: false)
    @archive_clients = Client.where(company: params[:company_id], archive: true)
  end

  # GET /clients/1
  # GET /clients/1.json
  def show
    @record_client = RecordClient.where(client_id: params[:id])

    
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
        format.html { render :new }
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
