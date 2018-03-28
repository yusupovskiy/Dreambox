class Companies::WindowsController < ApplicationController
  def show
    render layout: params[:layout]
  end
end
