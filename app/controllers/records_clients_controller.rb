class RecordsClientsController < ApplicationController
  before_action :confirm_actions, only: [:create, :update, :destroy]

  def create
    pms = record_client_params
    record = Record.find_by id: params[:record_client][:record_id]

    if !Client.exists? company_id: @current_company, id: params[:record_client][:client_id]
      messege = {complited: false, note: 'Нет такого клиента для записи'}

    elsif !@current_record.exists? id: params[:record_client][:record_id]
      messege = {complited: false, note: 'Нет такой записи'}

    elsif (@current_company.record_limit - @current_clients_company.count) <= 0
      messege = {complited: false, note: 'Вы достигли лимита по тарифу'}
    
    elsif record.finished_at.present? and record.finished_at < Date.today
      messege = {complited: false, note: 'Невозможно совершить запись когда ее срок истек'}

    else
      if record_client = RecordClient.find_by(pms.permit(:record_id, :client_id))
        record_client.update_attribute(:is_active, true)
      else
        record_client = RecordClient.create!(pms.merge(is_automatic: false, is_dynamic: false))
      end

      messege = {complited: true, note: 'Клиент записан'}
    end

    respond_to do |format|
      format.json { render json: messege }
    end
  end

  def destroy
    client_id = params[:client_id]
    record_id = params[:record_id]

    if !Client.exists? company_id: @current_company, id: client_id
      messege = {complited: false, note: 'Нет такого клиента для отписки'}

    elsif !Record.exists? id: record_id
      messege = {complited: false, note: 'Нет такой записи для отписки'}

    elsif client_id.present? and record_id.present?
      rc = RecordClient.find_by(record_id: record_id, client_id: client_id)
      rc.update_attribute(:is_active, false)

      messege = {complited: true, note: 'Клиент отписан'}

    else
      messege = {complited: false, note: 'Отписать не удалось'}
    end

    respond_to do |format|
      format.json { render json: messege }
    end
  end

  private
    def record_client_params
      params.require(:record_client)
        .permit(:record_id, :client_id, :is_active, :is_automatic)
    end
end
