class DiscountsController < ApplicationController
  before_action :confirm_actions, only: [:create, :update, :destroy]

  def index
    records_clients = RecordClient.where record_id: @current_record
    discounts = Discount.where(record_client_id: records_clients).order('created_at DESC')

    respond_to do |format|
      format.json { render json: discounts }
    end
  end

  def create
    discount = Discount.new discount_params
    result = []

    records_id = @current_record.ids.join(", ")
    records = Record.find_by_sql("
      SELECT  r.*, coalesce(SUM(rs.money_for_abon),0) AS total_price_abon, rc.id
      FROM records AS r
        LEFT JOIN records_services AS rs
          ON r.id = rs.record_id
        LEFT JOIN records_clients AS rc
          ON r.id = rc.record_id
      WHERE r.id IN (#{records_id}) AND rc.id = #{discount.record_client_id}
      GROUP BY r.id, rc.id
      ORDER BY r.finished_at DESC
    ")

    if discount.value == records[0].total_price_abon
      complited = false
      note = "Цена не должна равняться текущей"

    elsif discount.note == ''
      complited = false
      note = "Нужно указать комментарий"

    elsif discount.save
      complited = true
      # note = "Скидка или коррекция добавлена"
      if discount.value > records[0].total_price_abon
        note = "Коррекция добавлена"
      elsif discount.value < records[0].total_price_abon
        note = "Скидка добавлена"
      end
      result = discount

    else
      complited = false
      note = "Действие произведено"
    end

    messege = {complited: complited, note: note, result: result}

    respond_to do |format|
      format.json { render json: messege }
    end
  end

  private
    def discount_params
      params.require(:discount)
        .permit(:record_client_id, :note, :value, :start_at, :finish_at)
    end
end
