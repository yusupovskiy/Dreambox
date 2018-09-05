class CategoriesController < ApplicationController

  def get_categories_income
    categories_income = Category.where budget: 'income', subject: 'company'

    respond_to do |format|
      format.json { render json: categories_income }
    end
  end

  def get_categories_expense
    categories_income = Category.where budget: 'expense', subject: 'company'

    respond_to do |format|
      format.json { render json: categories_income }
    end
  end
end