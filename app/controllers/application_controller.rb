class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :ensure_current_user
  before_action :store_user_location!, if: :storable_location?
  before_action :authenticate_user!
  before_action :set_locale
  before_action :access_levels


  
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

    def after_sign_in_path_for(resource)
      params[:return_url] || '/'
    end
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
      # redirect_to user_session_path, notice: t('devise.failure.unauthenticated') if current_user.nil?
      # @current_company = Company.find_by_id(params[:company_id])
      # redirect_to root_path, notice: t('company.not_yours') unless @current_company.user_id == @current_user.id
      # redirect_to new_company_path, notice: t('create_a_company_first') if @current_company.nil?
    end
    def confirm_actions
      unless Work.exists? people_id: @current_people.id, position_work: 'director' or Work.exists? people_id: @current_people.id, position_work: 'administrator'
        return redirect_to request.referer, notice: "Для этого действия, у вас нет нужного уровня доступа"
      end
    end

    def access_levels
      if signed_in?
        presence_of_viewing_object = Client.exists? id: current_user.people_id
        @url = request.original_url.split('/')

        if presence_of_viewing_object
          @current_people = Client.find_by id: current_user.people_id

          @user_director = Work.exists? people_id: @current_people.id, position_work: 'director'
          @user_administrator = Work.exists? people_id: @current_people.id, position_work: 'administrator'
          @user_client = (@current_people.role.to_i & Client::Role::CLIENT) > 0

          @current_company = Company.find @current_people.company_id
          @expired = @current_company.time_limit >= Date.today

          ra = Record.where affiliate_id: Affiliate.where(company_id: @current_company)
          rc = RecordClient.where(record_id: ra, is_active: true)

          @total_clients_company = Client.where("company_id = #{} and (role & #{Client::Role::CLIENT}) != 0")
          
          @current_clients_company = Client.where id: rc.select(:client_id)

          if @user_director
            unless @expired
              unless @url.last == 'company' or @url.last(2) == ["clients", "#{@current_people.id}"] or @url[3] == 'persons' or @url.last(2) == ["auth", "edit"] or @url.last(2) == ["companies", "new"] or @url.last == 'sign_out' or @url.last == 'companies' or @url[3] == 'auth'
                return redirect_to company_path, notice: "Запрещено, пока не продлите подписку"
              end
            else
              @current_affiliates = Affiliate.where company_id: @current_company
              @current_record = Record.where affiliate_id: @current_affiliates
            end

          elsif @user_administrator
            unless @expired
              unless @url.last == 'company' or @url.last(2) == ["clients", "#{@current_people.id}"] or @url[3] == 'persons' or @url.last(2) == ["auth", "edit"] or @url.last(2) == ["companies", "new"] or @url.last == 'sign_out' or @url.last == 'companies' or @url[3] == 'auth'
                return redirect_to company_path, notice: "Запрещено, пока не продлите подписку"
              end
            else
              client_work = Work.where people_id: @current_people.id, is_active: true
              work_salary = WorkSalary.where work_id: client_work.select(:id), is_active: true
              @current_affiliates = Affiliate.where id: work_salary.select(:affiliate_id)

              @current_record = Record.where affiliate_id: @current_affiliates
            end

          elsif @user_client
            @current_affiliates = Affiliate.where id: 0
            @current_record = Record.where(id: 0)
            unless @url.last(2) == ["clients", "#{@current_people.id}"] or @url[3] == 'persons' or @url.last(2) == ["auth", "edit"] or @url.last(2) == ["companies", "new"] or @url.last == 'sign_out' or @url.last == 'companies' or @url[3] == 'auth'
              return redirect_to company_client_path(1, @current_people.id)
            end
          end
          
        else
          unless @url[3] == 'persons' or @url.last == 'edit' or @url.last == 'new' or @url.last == 'sign_out'  or @url.last == 'companies' 
            return redirect_to persons_profile_path, notice: "Создайте или выберите компанию"
          end
        end      
      end
    end

    def set_locale
      I18n.locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first.presence || 'en'
    end
end
