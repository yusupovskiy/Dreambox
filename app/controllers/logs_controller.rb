class LogsController < ApplicationController
  def index
    logs = OperationLog.find_by_sql("
      SELECT l.id, l.note, l.created_at, l.type_log, s.id AS user_id, s.last_name || ' ' || s.first_name AS user_name, s.avatar, ol.operation_id
      FROM operation_logs AS ol
        LEFT JOIN logs AS l
          ON ol.log_id = l.id
        LEFT JOIN users AS s
          ON l.user_id = s.id
          
      ORDER BY l.created_at DESC
    ")
    
    respond_to do |format|
      format.json { render json: logs, status: :ok }
    end
  end
end
