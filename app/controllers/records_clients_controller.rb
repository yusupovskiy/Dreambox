class RecordsClientsController < ApplicationController

  def create
    record_client = RecordClient.create!(record_client_params.merge(is_automatic: false, is_dynamic: false))

    respond_to do |format|
      format.html { redirect_to request.referer }
      format.json { render json: record_client }
    end
  end

  def destroy
    rc = RecordClient.find(params[:id])
    rc.destroy!

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
