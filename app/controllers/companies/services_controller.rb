class Companies::ServicesController < ApplicationController
  before_action :confirm_actions, only: [:create, :update, :destroy, :new, :edit]
  before_action :set_companies_service, only: [:show, :edit, :update, :destroy]

  def index
    # services = Service.find_by_sql("
    #   SELECT s.* , array_agg(DISTINCT rs.record_id ORDER BY rs.record_id) AS records_id
    #   FROM services AS s
    #     LEFT JOIN records_services AS rs
    #       ON s.id = rs.service_id
          
    #   WHERE s.company_id = #{@current_company.id}
    #   GROUP BY s.id
    #   ORDER BY created_at DESC 
    # ")

    # services = Service.where(company_id: @current_company.id).order('created_at DESC')
    services = Service.all

    respond_to do |format|
      format.json { render json: services, status: :ok }
    end
  end

  def show
  end

  def new
    @service = Service.new company_id: @current_company.id
    @title_card = 'Добавление услуги'
    @form_submit = 'Сохранить'

    if request.referrer == request.original_url or request.referrer == nil
      @url_back = clients_path
    else
      @url_back = request.referrer
    end
  end

  def edit
    @title_card = 'Редактирование услуги'
    @form_submit = 'Изменить'
  end

  def create
    @service = Service.new(service_params)

    respond_to do |format|
      if @service.save
        format.html { redirect_to clients_path, notice: t('service.created') }
        format.json { render :show, status: :created }
      else
        format.html { redirect_to request.referer }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @service.update(service_params)
        format.html { redirect_to [@service], notice: t('service.updated') }
        format.json { render :show, status: :ok, location: @service }
      else
        format.html { render :edit }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @service.destroy
    respond_to do |format|
      format.html { redirect_to services_url, notice: t('service.destroyed') }
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
