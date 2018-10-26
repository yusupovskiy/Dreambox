class RecordsServicesController < ApplicationController
  before_action :confirm_actions, only: [:create, :update, :destroy]
  before_action :record_service_params, only: :create
  layout false

  def index
    # if @current_record.exists? params[:record_id]
    #   records_services = @current_record.find(params[:record_id]).record_service.eager_load(:service).order('services.created_at')

      records_services = RecordService.where(record_id: @current_record).order('created_at DESC')

      respond_to do |format|
        format.json { render json: records_services }
      end
    # end
  end

  def create
    pms = record_service_params
    record = Record.eager_load(:affiliate).find pms[:record_id]
    # service = Service.eager_load(:company).find pms[:service_id]
    category = Category.find_by id: pms[:category_id], company_id: @current_company.id, subject: 'company'
    result = []

    rs = RecordService.new pms
    rs.money_for_abon = 0 if not rs.money_for_abon.nil? and rs.money_for_abon < 0
    rs.money_for_visit = 0 if not rs.money_for_visit.nil? and rs.money_for_visit < 0

    if RecordService.exists? record_id: record.id, category_id: category.id
      complited = false
      note = 'Выборанная услуга уже указана'

    elsif !(Category.exists? id: pms[:category_id])
      complited = false
      note = 'Нет такой услуги'

    elsif !(Record.exists? id: pms[:record_id])
      complited = false
      note = 'Нет такой записи'

    elsif !(rs.money_for_abon > 0)
      complited = false
      note = 'Цена должна быть больше нулю'

    elsif rs.save
      complited = true
      note = 'Услуга прикреплена'
      result = rs
    end

    messege = {complited: complited, note: note, result: result}

    respond_to do |format|
      format.json { render json: messege }
    end
  end

  def update
    pms = record_service_params
    ids = pms.permit(:record_id, :category_id)
    record_service = RecordService.find_by(ids)
    pms.delete(:record_id)
    pms.delete(:category_id)

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
    # record = RecordService.eager_load(:service)
    #   .find_by(record_id: pms[:record_id], category_id: pms[:category_id])

    # if record.service.company.user_id != current_user.id
    #   complited = false
    #   note = 'В компании нет такой услуги'

    if !(@current_record.exists? id: pms[:record_id])
      complited = false
      note = 'Нет такой записи'

    else
      complited = true
      note = 'Услуга откреплена'
      RecordService.where(record_id: pms[:record_id], category_id: pms[:category_id]).delete_all
    end
  
    messege = {complited: complited, note: note}

    respond_to do |format|
      format.json { render json: messege, method: :delete }
    end
  end

  private
    def record_service_params
      params.require(:record_service)
        .permit(:record_id, :category_id, :money_for_abon, :money_for_visit)
    end
end