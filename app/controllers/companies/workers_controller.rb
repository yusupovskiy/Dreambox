class Companies::WorkersController < ApplicationController
  before_action :confirm_actions, only: [:create, :update, :destroy, :new, :edit]
  before_action :set_company
  
  def index
    @people = Client.where(company: @current_company.id)
    @clients = @people.where("(role & #{Client::Role::STUFF}) != 0")

    @all_people = @clients
    @show_in_view = [@all_people]
  	render :template => 'companies/people/index'
  end
  def show

  	render :template => 'companies/people/show'
  end
end
