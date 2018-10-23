class CategoriesController < ApplicationController
  def get_categories
    categories = Category.where(subject: 'company').order(:id)

    respond_to do |format|
      format.json { render json: categories }
    end
  end
end