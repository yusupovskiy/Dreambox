class CategoriesController < ApplicationController
  def create
    @category = Category.new(params.require(:category).permit(:name, :budget, :level, :color))
    @category.company_id = @current_company.id
    @category.subject = 'company'
    result = []

    present_level_category = Category.where("subject = 'company' 
                            AND (company_id IS NULL 
                              OR company_id = #{@current_company.id}) 
                            AND (id = #{@category.level} 
                              OR 0 = #{@category.level})").present?

    if @category.level.nil?
      complited = false
      note = 'Не указан уровень категории'

    elsif !present_level_category
      complited = false
      note = 'Указанного уровня не существует'

    elsif (@category.budget == 'income' or @category.budget == 'expense') and @category.save
      complited = true
      note = 'Категория создана'
      result = @category

    else
      complited = false
      note = 'Категория не создана'
    end

    messege = { complited: complited, note: note, result: result }

    respond_to do |format|
      format.json { render json: messege }
    end
  end
end