class Companies::WorksController < ApplicationController
  before_action :set_people
  before_action :set_company
  before_action :set_access
  before_action :set_affiliate
  before_action :confirm_actions, only: [:create, :update, :destroy]

  def create
    prms = params.require(:work).permit(:people_id, :position_work, 
      :fixed_rate, :affiliate_id)
    work = Work.new(prms)

    affiliates_company = Affiliate.where company_id: @current_company.id

    director_work = Work.where position_work: 'director', affiliate_id: affiliates_company.select('id')
    user_director_work = Work.where people_id: @current_people.id, position_work: 'director'

    if (work.position_work == 'administrator' or 
        work.position_work == 'moderator' or 
        work.position_work == 'accountant' or 
        work.position_work == 'director') and 
        user_director_work.empty?
      return redirect_to request.referer, notice: "Нет полномочий для добавления таких должностей"
    end
    if work.position_work == 'director' and director_work.present?
      return redirect_to request.referer, notice: "Должность \"Директор\" в этой компании уже занята"
    end
    if work.save
      redirect_to request.referer, notice: "Назначен на должность #{t('position_work.' + work.position_work)}"
    else
      redirect_to request.referer, notice: "Не назначен"
    end
  end
end
