class Companies::SalariesController < ApplicationController
  def show
    
  end
  def create
    prms = params.require(:salary).permit(:start_at, :finish_at, 
      :work_id)
    salary = Salary.new(prms)

    # salary.pay

  end
end
