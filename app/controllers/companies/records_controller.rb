class Companies::RecordsController < ApplicationController
  before_action :set_people
  before_action :set_company
  before_action :set_access
  before_action :set_affiliate
  before_action :confirm_actions, only: [:create, :update, :destroy, :new, :edit]
  before_action :ensure_user_has_company

  # GET /records
  # GET /records.json
  def index
    ids = @current_company.affiliates.select(:id)
    @records = Record.where(affiliate: ids)
    @completed_records = @current_record.where("finished_at < ?", Date.today)
    @no_completed_records = @current_record.where("finished_at > ?", Date.today)

  end

  # GET /records/1
  # GET /records/1.json
  def show
    # unless @record.affiliate.company_id == @current_company.id
    #   return render html: "Record with id = #{@record.id} does not belong to you"
    # end
    @services = Service.where(company_id: @current_company.id)
    @record_client = RecordClient.new(record_id: params[:id])
    @clients = Client.where("(role & #{Client::Role::CLIENT}) != 0 
      AND archive = false
      AND company_id = #{@current_company.id}
    ")
    @records_clients = RecordClient.where(record_id: params[:id], is_active: true)

    @potential_clients = @clients.where.not(id: @records_clients.select('client_id'))
    @subscription = Subscription.new



  end

  # GET /records/new
  def new
    @record = Record.new
    @services = Service.where(company_id: @current_company.id)
  end

  # GET /records/1/edit
  def edit
    @services = Service.where(company_id: @current_company.id)
  end

  # POST /records
  # POST /records.json
  def create
    @record = Record.new(record_params)
    ids = params[:record][:service_ids]
    money = params[:record][:service_money]
    #raise 'Wrong request'unless ids.size == money.size

    #ids.size.times do |i|
    #  @record.record_service << RecordService.new(service_id: ids[i], money: money[i])
    #end


    respond_to do |format|
      if @record.save
        format.html { redirect_to [@record.affiliate.company, @record], notice: "<hr class=\"status-complet completed\" />Запись была успешно создана" }
        format.json { render :show, status: :created, location: @record }
      else
        format.html { render :new }
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /records/1
  # PATCH/PUT /records/1.json
  def update
    respond_to do |format|
      if @record.update(record_params)
        format.html { redirect_to [@record.affiliate.company, @record], notice: "<hr class=\"status-complet completed\" />Запись была успешно обновлена" }
        format.json { render :show, status: :ok, location: @record }
      else
        format.html { render :edit }
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /records/1
  # DELETE /records/1.json
  def destroy
    @record.destroy
    respond_to do |format|
      format.html { redirect_to company_records_path(@current_company.id), notice: 'Record was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_record
    #   @record = Record.eager_load(:affiliate).find(params[:id])
    # end

    # Never trust parameters from the scary internet, only allow the white list through.
    def record_params
      params.require(:record)
        .permit(:name, :abon_period, :total_clients, :total_visits,
                :created_at, :finished_at, :affiliate_id,
                :record_type, :visit_type, :is_automatic)
    end
    # def set_company
    #   current_client = Client.find current_user.people_id
    #   @current_company = Company.find(current_client.company_id)
    # end
end
