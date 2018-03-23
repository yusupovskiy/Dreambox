class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?


  private
    def configure_permitted_parameters
      keys = [:first_name, :last_name, :patronymic, :birthday]
      devise_parameter_sanitizer.permit(:sign_up, keys: keys)
      devise_parameter_sanitizer.permit(:account_update, keys: keys)
    end

    def after_sign_up_path_for(resource)
      params[:return_url] || '/'
    end

    def after_sign_in_path_for(resource)
      params[:return_url] || '/'
    end
    def ensure_current_user
      redirect_to new_user_session_path(return_url: request.url) if current_user.nil?
    end
end
