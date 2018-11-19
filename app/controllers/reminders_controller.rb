class RemindersController < ApplicationController

  def index
    affiliates = Affiliate.where company_id: @current_company
    reminders = Reminder.where affiliate_id: affiliates

    respond_to do |format|
      format.json { render json: reminders }
    end
  end

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
    end

    messege = { complited: complited, note: note, result: reminder }

    respond_to do |format|
      format.json { render json: messege }
    end
  end
end
