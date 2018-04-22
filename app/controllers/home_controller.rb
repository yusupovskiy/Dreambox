class HomeController < ApplicationController
  layout 'application'
  def index
    # NotificationMailer.welcome.deliver_later
  end
end
