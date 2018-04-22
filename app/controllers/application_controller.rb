class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :ensure_current_user
  before_action :authenticate_user!
  layout 'card'
  before_action :set_locale


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
        p redirect_to new_company_path, notice: t('create_a_company_first')
      end
    end
    def set_locale
      I18n.locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first.presence || 'en'
      p I18n.locale
    end
end
