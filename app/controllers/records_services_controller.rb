class RecordsServicesController < ApplicationController
  before_action :set_record_service, only: :destroy
  before_action :record_service_params, only: :create
  layout false

  def index
    record = Record.eager_load('affiliate').find(params[:record_id])
    return render plain: 'The record is not yours', status: 401 unless record.company.user_id == current_user.id
    @records_services = record.record_service.eager_load(:service)
  end

  def create
    pms = record_service_params
    record = Record.eager_load(:affiliate).find pms[:record_id]
    service = Service.eager_load(:company).find pms[:service_id]
    unless service.company_id == record.affiliate.company_id
      return render plain: 'record.company is not service.affiliate.company', status: 400
    end

    unless service.company.user_id == current_user.id
      return render plain: 'current user has not the company of the record', status: 400
    end


    rs = RecordService.create! pms
    respond_to do |format|
      format.json { render json: rs, status: 201 }
    end
  end

  def destroy
    pms = record_service_params
    record = RecordService.eager_load(:service)
      .find_by(record_id: pms[:record_id], service_id: pms[:service_id])

    unless record.service.company.user_id == current_user.id
      return render plain: 'The company of this record does not belong to you', status: 400
    end
    
    # we cannot "record.delete" because of double primary key
    RecordService.where(record_id: pms[:record_id], service_id: pms[:service_id]).delete_all
    respond_to do |format|
      format.json { render plain: 'ok', status: 204 }
    end
  end

  private
    def set_record_service
      @record_service = RecordService.find(params[:id]) if params[:id]
    end
    def record_service_params
      params.require(:record_service)
        .permit(:record_id, :service_id, :money_for_abon, :money_for_visit)
    end
end