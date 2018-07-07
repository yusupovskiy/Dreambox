class PersonsController < ApplicationController
  before_action :set_company
  
  def profile
  	@people_user = Client.where user_id: current_user.id
    @company = Company.new
  end

  def new_profile
  end

  def role_person
    people_user = Client.where user_id: current_user.id
    confirmation = people_user.where id: params[:role_person]

    if confirmation.present?
      current_user.update_attribute(:people_id, params[:role_person])
      redirect_to root_path, notice: "Действие произведено"
    else
      redirect_to request.referer, notice: "В доступе отказано"
    end
  end
end