class WindowsController < ApplicationController
  before_action :set_company
  
  def show
    window_id = params[:id]
    render window_id, layout: params[:layout]
  end
end
