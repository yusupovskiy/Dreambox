class Companies::WorksController < ApplicationController
  before_action :confirm_actions, only: [:create, :update, :destroy]

  def get_works
    works = Work.where affiliate_id: @current_affiliates

    respond_to do |format|
      format.json { render json: works, status: :ok }
    end
  end

  def create
    prms = params.require(:work).permit(:people_id, :position_work, 
      :fixed_rate, :affiliate_id)
    work = Work.new(prms)
    result = []

    operation = Operation.create
    work.operation_id = operation.id

    director_work = Work.where position_work: 'director', affiliate_id: @current_affiliates
    user_director_work = Work.where position_work: 'director', people_id: @current_people.id
    user_administrator_work = Work.where position_work: 'administrator', people_id: @current_people.id

    if work.affiliate_id.nil?
      complited = false
      note = 'Нужно указать место работы'

    elsif user_director_work.empty? and user_administrator_work.empty?
      complited = false
      note = 'Нет полномочий для добавления должностей'

    elsif work.position_work == 'director' and director_work.present?
      complited = false
      note = 'Должность "Директор" в компании уже занята'

    elsif work.save
      complited = true
      note = "Назначен на должность #{t('position_work.' + work.position_work)}"
      result = work

    else
      complited = false
      note = 'Не назначен'
    end

    messege = {complited: complited, note: note, result: result}

    respond_to do |format|
      format.json { render json: messege }
    end
  end
end
