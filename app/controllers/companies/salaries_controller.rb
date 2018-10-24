class Companies::SalariesController < ApplicationController
  before_action :confirm_actions, only: [:create]
  
  def create
    prms = params.require(:salary).permit(:start_at, :finish_at, 
      :work_id)
    salary = Salary.new(prms)

    operation = Operation.create
    salary.operation_id = operation.id
    
    # salary.pay

  end
end
