class RecordsController < ApplicationController
  before_action :confirm_actions, only: [:create, :update, :destroy, :new, :edit]
  before_action :ensure_user_has_company
  before_action :set_record, only: [:show, :edit, :update]

  def get_records
    records_id = @current_record.ids.join(", ")

    if records_id.empty?
      records = []
    else
      records = Record.find_by_sql("
        SELECT  r.*, coalesce(SUM(rs.money_for_abon),0) AS total_price_abon
        FROM records AS r
          LEFT JOIN records_services AS rs
            ON r.id = rs.record_id
        WHERE r.id IN (#{records_id})
        GROUP BY r.id
        ORDER BY r.name
      ")
        # ORDER BY r.finished_at DESC
    end

    respond_to do |format|
      format.json { render json: records, status: :ok }
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
