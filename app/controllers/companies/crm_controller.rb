class Companies::CrmController < ApplicationController
  def index
    @clients = Client.where(company: params[:company_id])
  end
end
