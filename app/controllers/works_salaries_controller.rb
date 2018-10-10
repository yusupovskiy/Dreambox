class WorksSalariesController < ApplicationController
  before_action :confirm_actions, only: [:create, :update, :destroy]
  before_action :access_level
  
  def get_works_affiliates
    works_affiliates = WorkSalary.where affiliate_id: @current_affiliates

    respond_to do |format|
      format.json { render json: works_affiliates, status: :ok }
    end
  end

  def create
    prms = params.require(:work_salary).permit(:work_id, :affiliate_id)
    work_salary = WorkSalary.new(prms)
    result = []

    work = Work.find work_salary.work_id
    works_worker = Work.where people_id: work.people_id

    company_work_salary = WorkSalary.where work_id: works_worker, affiliate_id: @current_affiliates
    affiliate_work_salary = company_work_salary.where affiliate_id: work_salary.affiliate_id
    
    if @access_director.empty?
      complited = false
      note = 'У вас нет полномочий руководителя чтобы открыть доступ к филиалу'

    elsif affiliate_work_salary.present?
      complited = false
      note = 'Этот филиал уже зянят другой должностью'

    elsif work.position_work == 'director'
      complited = false
      note = 'У должности "Директора", уже имеется доступ ко всей информации филиалов'

    elsif work_salary.save
      complited = true
      note = 'Получил доступ к филиалу'
      result = work_salary

    else
      complited = false
      note = 'Не получил доступ к филиалу'
    end

    messege = {complited: complited, note: note, result: result}

    respond_to do |format|
      format.json { render json: messege }
    end
  end

  def destroy
    work_salary = WorkSalary.find_by work_id: params[:work_id], affiliate_id: params[:affiliate_id], affiliate_id: @current_affiliates

    if @access_director.empty?
      complited = false
      note = 'У вас нет полномочий руководителя для удаления'

    elsif !work_salary.present?
      complited = false
      note = 'Нет такой связки'

    elsif work_salary.destroy
      complited = true
      note = 'Теперь доступ к филиалу у сотрудника ограничен'

    else
      complited = false
      note = 'Не вышло'
    end

    messege = {complited: complited, note: note}

    respond_to do |format|
      format.json { render json: messege }
    end
  end

  private
    def access_level
      @access_director = Work.where people_id: @current_people.id, position_work: 'director'
    end
end
