class WindowsController < ApplicationController
  def show
    window_id = params[:id]
    render window_id, layout: params[:layout]
  end
end
