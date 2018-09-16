class RecordsController < ApplicationController
  before_action :confirm_actions, only: [:create, :update, :destroy, :new, :edit]
  before_action :ensure_user_has_company
  before_action :set_record, only: [:show, :edit, :update]

  def get_subs_client
    record_id = params[:record_id]
    client_id = params[:client_id]

    rc = RecordClient.find_by record_id: record_id, client_id: client_id

    s = Subscription.where(record_client_id: rc.id, is_active: true).order('start_at DESC')

    respond_to do |format|
      format.json { render json: s, status: :ok }
    end
  end

  def get_records
    records = @current_record.order('finished_at DESC')

    respond_to do |format|
      format.json { render json: records, status: :ok }
    end
  end

  def get_select_records_client
    id_client = params[:client_id]
    
    records_client = RecordClient.where(client_id: id_client, record_id: @current_record)
    completed_records = @current_record.where("finished_at < ?", Date.today)
    no_completed_records = @current_record.where.not(id: completed_records)
    no_records_client = no_completed_records.where.not(id: records_client.where(is_active: :true).select(:record_id))


    respond_to do |format|
      format.json { render json: no_records_client, status: :ok }
    end
  end
  
  def index
    ids = @current_company.affiliates.select(:id)
    @records = Record.where(affiliate: ids)
    @completed_records = @current_record.where("finished_at < ?", Date.today)
    @no_completed_records = @current_record.where.not(id: @completed_records)

  end

  def new
    @record = Record.new
    @title_card = 'Добавление записи'
    @form_submit = 'Сохранить'

    if request.referrer == request.original_url or request.referrer == nil
      @url_back = clients_path
    else
      @url_back = request.referrer
    end
  end

  # GET /records/1/edit
  def edit
    @title_card = 'Редактирование группы'
    @form_submit = 'Изменить'

    if request.referrer == request.original_url or request.referrer == nil
      @url_back = clients_path
    else
      @url_back = request.referrer
    end
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
    
    operation = Operation.create
    @record.operation_id = operation.id

    respond_to do |format|
      if @record.save
        format.html { redirect_to "/clients?record=#{@record.id}", notice: "Запись была успешно создана" }
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
        format.html { redirect_to "/clients?record=#{@record.id}", notice: "Запись была успешно обновлена" }
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

  def end_recording
    record = Record.find params[:id]
    record.update_attribute(:finished_at, Date.today - 1)
    redirect_to request.referer, notice: "Запись завершена"
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
                :record_type, :visit_type, :subscription_sale)
    end
    # def set_company
    #   current_client = Client.find current_user.people_id
    #   @current_company = Company.find(current_client.company_id)
    # end
end
