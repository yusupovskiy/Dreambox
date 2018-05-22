class HomeController < ApplicationController
  layout 'application'

  def index
    # TODO: remember the last used company instead of choose the first one
    @current_company = current_user.companies.first
    # NotificationMailer.welcome.deliver_later
  end

  def search_result
  	@search_request = params[:request]
  	if @search_request.size == 1 and @search_request[0].size >= 1 or @search_request[1].size == 0
  		@products = Client.where("LOWER(last_name) LIKE LOWER('#{@search_request[0]}%')")
  	elsif @search_request.size == 2 and @search_request[1].size >= 1 or @search_request[2].size == 0
  		@products = Client.where("LOWER(last_name) LIKE LOWER('%#{@search_request[0]}%') AND LOWER(first_name) LIKE LOWER('#{@search_request[1]}%')")
  	elsif @search_request.size == 3 and @search_request[2].size >= 1
  		@products = Client.where("LOWER(last_name) LIKE LOWER('#{@search_request[0]}%') AND LOWER(first_name) LIKE LOWER('#{@search_request[1]}%') AND LOWER(patronymic) LIKE LOWER('#{@search_request[2]}%')")
	else
		@products = ""
	end

  	render layout: false
  end

end
