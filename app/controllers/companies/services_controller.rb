class Companies::ServicesController < ApplicationController
  before_action :set_companies_service, only: [:show, :edit, :update, :destroy]
  layout 'card'

  # GET /companies/services
  # GET /companies/services.json
  def index
    @services = Service.where(company_id: @current_company.id)
    @total_services = @services.count
  end

  # GET /companies/services/1
  # GET /companies/services/1.json
  def show
  end

  # GET /companies/services/new
  def new
    @service = Service.new company_id: @current_company.id
  end

  # GET /companies/services/1/edit
  def edit
  end

  # POST /companies/services
  # POST /companies/services.json
  def create
    @service = Service.new(service_params)

    respond_to do |format|
      if @service.save
        format.html { redirect_to [@service.company, @service], notice: t('service.created') }
        format.json { render :show, status: :created }
      else
        format.html { render :new }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/services/1
  # PATCH/PUT /companies/services/1.json
  def update
    respond_to do |format|
      if @service.update(service_params)
        format.html { redirect_to [@service.company, @service], notice: t('service.updated') }
        format.json { render :show, status: :ok, location: @service }
      else
        format.html { render :edit }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/services/1
  # DELETE /companies/services/1.json
  def destroy
    @service.destroy
    respond_to do |format|
      format.html { redirect_to company_services_url, notice: t('service.destroyed') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_companies_service
      @service = Service.where(company_id: @current_company.id).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def service_params
      params.require(:service)
          .permit(:name)
          .merge(company_id: @current_company.id)
    end
end
