class HomeController < ApplicationController
  layout 'application'
  def index
    # TODO: remember the last used company instead of choose the first one
    @current_company = current_user.companies.first
    # NotificationMailer.welcome.deliver_later
  end
end
