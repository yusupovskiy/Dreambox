class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :ensure_current_user
  before_action :store_user_location!, if: :storable_location?
  before_action :authenticate_user!
  before_action :set_locale
  layout 'card'


  private
    # def current_user
    #   @current_user ||= User.eager_load(:@current_company).find
    # end
    def configure_permitted_parameters
      keys = [:first_name, :last_name, :patronymic, :birthday]
      devise_parameter_sanitizer.permit(:sign_up, keys: keys)
      devise_parameter_sanitizer.permit(:account_update, keys: keys)
    end

    def after_sign_up_path_for(resource)
      params[:return_url] || '/'
    end

    # def after_sign_in_path_for(resource)
    #   params[:return_url] || '/'
    # end
    def storable_location?
      request.get? && is_navigational_format? && !devise_controller? && !request.xhr? 
    end
    def store_user_location!
      # :user is the scope we are authenticating
      store_location_for(:user, request.path)
    end
    def ensure_current_user
      # if !signed_in? and request.get? and
      #    params[:controller] != 'users'
      #   p redirect_to new_user_session_path(return_url: request.url)
      # end
    end
    def ensure_company_owner_role
      if current_user.nil? and current_user.role & User::Role::COMPANY_OWNER == 0
        redirect_to new_company_path, notice: t('create_a_company_first')
      end
    end
    def ensure_user_has_company
      redirect_to user_session_path, notice: t('devise.failure.unauthenticated') if current_user.nil?
      @current_company = Company.find_by_id(params[:company_id])
      redirect_to root_path, notice: t('company.not_yours') unless @current_company.user_id == @current_user.id
      redirect_to new_company_path, notice: t('create_a_company_first') if @current_company.nil?
    end
    def set_locale
      I18n.locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first.presence || 'en'
    end
end
