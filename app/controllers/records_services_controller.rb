class RecordsServicesController < ApplicationController
  before_action :set_people
  before_action :set_company
  before_action :set_access
  before_action :set_affiliate
  before_action :confirm_actions, only: [:create, :update, :destroy]
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

    rs = RecordService.new pms
    rs.money_for_abon = 0 if not rs.money_for_abon.nil? and rs.money_for_abon < 0
    rs.money_for_visit = 0 if not rs.money_for_visit.nil? and rs.money_for_visit < 0
    rs.save!
    respond_to do |format|
      format.json { render json: rs, status: 201 }
    end
  end

  def update
    pms = record_service_params
    ids = pms.permit(:record_id, :service_id)
    record_service = RecordService.find_by(ids)
    pms.delete(:record_id)
    pms.delete(:service_id)

    pms = Hash(pms)
    RecordService.where(ids).update_all(pms)
    record_service.assign_attributes(pms)
    respond_to do |format|
      # format.html { redirect_to record_service, notice: 'Record was successfully updated.' }
      format.json { render json: record_service, status: :ok }
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
    def record_service_params
      params.require(:record_service)
        .permit(:record_id, :service_id, :money_for_abon, :money_for_visit)
    end
end