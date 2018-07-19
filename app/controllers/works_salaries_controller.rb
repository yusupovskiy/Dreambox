class WorksSalariesController < ApplicationController
  before_action :confirm_actions, only: [:create, :update, :destroy]
  before_action :access_level
  
  def create
    prms = params.require(:work_salary).permit(:work_id, :affiliate_id)
    work_salary = WorkSalary.new(prms)
    affiliates_company = Affiliate.where company_id: @current_company.id
    work = Work.find work_salary.work_id
    company_work_salary = WorkSalary.where work_id: work.id, affiliate_id: affiliates_company.select('id')

    affiliate_work_salary = company_work_salary.where affiliate_id: work_salary.affiliate_id

    
    if @access_director.empty?
      return redirect_to request.referer, notice: "У вас нет полномочий руководителя чтобы открыть доступ к филиалу"
    end
    if affiliate_work_salary.present?
      return redirect_to request.referer, notice: "Этот филиал уже зянят другой должностью"
    end
    if work.position_work == 'director'
      return redirect_to request.referer, notice: "Имея должность \"руководителя\", уже имеет доступ ко всей информации филиалов"
    end
    if work_salary.save
      redirect_to request.referer, notice: "Получил доступ к филиалу"
    else
      redirect_to request.referer, notice: "Не получил доступ к филиалу"
    end
  end
  def destroy
    if @access_director.empty?
      return redirect_to request.referer, notice: "У вас нет полномочий руководителя для удаления"
    end
    work_salary = WorkSalary.find(params[:id])
    work_salary.destroy
    respond_to do |format|
      format.html { redirect_to request.referer, notice: "Теперь доступ к филиалу у сотрудника ограничен" }
      format.json { head :no_content }
    end
  end

  private
    def access_level
      @access_director = Work.where people_id: @current_people.id, position_work: 'director'
    end
end
