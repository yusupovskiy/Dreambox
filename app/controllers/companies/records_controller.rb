class Companies::RecordsController < ApplicationController
  before_action :set_record, only: [:show, :edit, :update, :destroy]
  before_action :set_company, only: [:index, :create, :show, :edit, :new]

  # GET /records
  # GET /records.json
  def index
    ids = @current_company.affiliates.select(:id)
    @records = Record.where(affiliate: ids)
  end

  # GET /records/1
  # GET /records/1.json
  def show
    unless @record.affiliate.company_id == @current_company.id
      render html: "Record with id = #{@record.id} does not belong to you"
    end
  end

  # GET /records/new
  def new
    @record = Record.new
    @services = Service.where(company_id: params[:company_id])
  end

  # GET /records/1/edit
  def edit
    @services = Service.where(company_id: params[:company_id])
  end

  # POST /records
  # POST /records.json
  def create
    @record = Record.new(record_params)
    ids = params[:record][:service_ids]
    money = params[:record][:service_money]
    raise 'Wrong request'unless ids.size == money.size

    ids.size.times do |i|
      @record.record_service << RecordService.new(service_id: ids[i], money: money[i])
    end


    respond_to do |format|
      if @record.save
        format.html { redirect_to [@record.affiliate.company, @record], notice: 'Record was successfully created.' }
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
        format.html { redirect_to [@record.affiliate.company, @record], notice: 'Record was successfully updated.' }
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
      format.html { redirect_to company_records_path(params[:company_id]), notice: 'Record was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_record
      @record = Record.eager_load(:affiliate).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def record_params
      params.require(:record)
        .permit(:name, :abon_period, :total_clients, :total_visits,
                :created_at, :finished_at, :affiliate_id,
                :record_type, :visit_type)
    end
    def set_company
      @current_company = Company.find(params[:company_id])
      render html: "Sorry, but the company with id = #{@current_company} is not yours" unless @current_company.user_id == current_user.id
    end
end
