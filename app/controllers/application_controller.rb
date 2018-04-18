class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :ensure_current_user
  before_action :authenticate_user!


  private
    # def current_user
    #   @current_user ||= User.eager_load(:company).find
    # end
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
      # if !signed_in? and request.get? and
      #    params[:controller] != 'users'
      #   p redirect_to new_user_session_path(return_url: request.url)
      # end
    end
    def ensure_company_owner_role
      if current_user.nil? and current_user.role & User::Role::COMPANY_OWNER == 0
        p redirect_to new_company_path, notice: 'Please, create a company first'
      end
    end
end
