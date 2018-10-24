class CategoriesController < ApplicationController
  def get_categories
    categories = Category.where(subject: 'company').order(:id)

    respond_to do |format|
      format.json { render json: categories }
    end
  end
  def get_services
    @services = []

    def find_children(level)
      services_children = Category.where(level: level).order(:id)
      id_categories_array = []
      if !(services_children.length > 0)
        return false
      end
      services_children.each do |i| 
        id_categories_array.push(i.id)
      end
      @services = @services | services_children
      find_children(id_categories_array)
    end

    find_children([1])

    respond_to do |format|
      format.json { render json: @services }
    end
  end
end