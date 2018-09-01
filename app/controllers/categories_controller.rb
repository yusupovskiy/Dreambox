class CategoriesController < ApplicationController
  def index
    categories_income = Category.where budget: 'income', subject: 'company'

    respond_to do |format|
      format.json { render json: categories_income }
    end
  end
end