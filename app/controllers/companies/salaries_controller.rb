class Companies::SalariesController < ApplicationController
  before_action :set_people
  before_action :set_company
  before_action :set_access
  before_action :set_affiliate
  before_action :confirm_actions, only: [:create]
  
  def create
    prms = params.require(:salary).permit(:start_at, :finish_at, 
      :work_id)
    salary = Salary.new(prms)

    # salary.pay

  end
end
