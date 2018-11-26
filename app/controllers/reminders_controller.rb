class RemindersController < ApplicationController
  def create
    prms = params.require(:reminder).permit(:note, :date, :debt, :client_id, :affiliate_id)
    reminder = Reminder.new prms
    result = []

    if !Client.exists? id: reminder.client_id, company_id: @current_company
      complited = false
      note = 'Нет такого клиента'

    elsif !Affiliate.exists? id: reminder.affiliate_id, company_id: @current_company
      complited = false
      note = 'Нет такого филиала'

    elsif !reminder.date.present?
      complited = false
      note = 'Дата не указана'

    elsif reminder.debt.present? && !(reminder.debt > 0)
      complited = false
      note = 'Задолжность должна быть больше нуля'

    elsif reminder.save
      complited = true
      note = 'Заметка добавлена'
      result = reminder

      operation = Operation.create client_id: reminder.client_id
      reminder.update_attribute :operation_id, operation.id

      log = Log.create note: note, user_id: current_user.id, type_log: 'create'
      operatin_log = OperationLog.create operation_id: reminder.operation_id, log_id: log.id

      log = OperationLog.find_by_sql("
        SELECT l.id, l.note, l.created_at, l.type_log, s.id AS user_id, s.last_name || ' ' || s.first_name AS user_name, s.avatar, ol.operation_id
        FROM operation_logs AS ol
          LEFT JOIN logs AS l
            ON ol.log_id = l.id
          LEFT JOIN users AS s
            ON l.user_id = s.id
        WHERE l.id = #{log.id}
      ")
    end

    messege = { complited: complited, note: note, result: reminder, 
                log: log[0] }

    respond_to do |format|
      format.json { render json: messege }
    end
  end

  def update_completed
    reminder_id = params[:id]
    completed = params[:completed]
    reminder = Reminder.find reminder_id

    if !Client.exists? id: reminder.client_id, company_id: @current_company
      complited = false
      note = 'Такого клиена нет в компании'

    elsif !@current_affiliates.exists? id: reminder.affiliate_id
      complited = false
      note = 'Такого филиала нет в компании'

    else
      reminder.update_attribute :completed, completed

      if reminder.completed
        note = 'Изменение статуса на "Выполнен"'

      elsif !reminder.completed
        note = 'Изменение статуса на "Не выполнен"'
      end

      complited = true

      log = Log.create note: note, user_id: current_user.id, type_log: 'update'
      operatin_log = OperationLog.create operation_id: reminder.operation_id, log_id: log.id
    
      log = OperationLog.find_by_sql("
        SELECT l.id, l.note, l.created_at, l.type_log, s.id AS user_id, s.last_name || ' ' || s.first_name AS user_name, s.avatar, ol.operation_id
        FROM operation_logs AS ol
          LEFT JOIN logs AS l
            ON ol.log_id = l.id
          LEFT JOIN users AS s
            ON l.user_id = s.id
        WHERE l.id = #{log.id}
      ")
    end

    messege = { complited: complited, note: note, result: reminder, 
                log: log[0] }

    respond_to do |format|
      format.json { render json: messege }
    end      
  end
end
