class RecordsClientsController < ApplicationController

  def create
    pms = record_client_params
    record = Record.find(params[:record_client][:record_id])

    respond_to do |format|
      if record.finished_at < Date.today
        format.html { redirect_to request.referer, notice: "<hr class=\"status-complet not-completed\" />Невозможно делать запись когда ее срок истек" }
      else
        if record_client = RecordClient.find_by(pms.permit(:record_id, :client_id))
          record_client.update_attribute(:is_active, true)
        else
          record_client = RecordClient.create!(pms.merge(is_automatic: false, is_dynamic: false))
        end

        format.html { redirect_to [record.company, record], notice: "<hr class=\"status-complet completed\" />Запись клиента: #{Record.find(record_client.record_id).name}" }
        format.json { render json: record_client }
      end
    end
  end

  def destroy
    rc = RecordClient.find(params[:id])
    if params[:deactivate_instead_of_destroying]
      rc.update_attribute(:is_active, false)
    else
      rc.destroy!
    end

    respond_to do |format|
      format.html { redirect_to request.referer }
      format.json { render json: rc }
    end
  end

  private
    def record_client_params
      params.require(:record_client)
        .permit(:record_id, :client_id, :is_active, :is_automatic)
    end
end
