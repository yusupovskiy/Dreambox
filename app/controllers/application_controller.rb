class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :ensure_current_user
  before_action :store_user_location!, if: :storable_location?
  before_action :authenticate_user!
  before_action :set_locale
  before_action :access_levels

  def get_data
    people = Client.where(company_id: @current_company)
    clients = Client.where(company_id: @current_company)
    records_clients = RecordClient.where record_id: @current_record
    subscriptions = Subscription.where(record_client_id: records_clients).order('start_at DESC')
    reminders = Reminder.where(affiliate_id: @current_affiliates)

    operations = Operation.where( id: clients.select(:operation_id) )
                 .or( Operation.where( id: @current_record.select(:operation_id) ) )
                 .or( Operation.where( id: subscriptions.select(:operation_id) ) )
                 .or( Operation.where( id: reminders.select(:operation_id) ) )
      # OR id IN #{works.select(:operation_id)}
      # OR id IN #{salaries.select(:operation_id)}

    operations_id = operations.ids.join(", ")
    logs = OperationLog.find_by_sql("
      SELECT l.id, l.note, l.created_at, l.type_log, s.id AS user_id, s.last_name || ' ' || s.first_name AS user_name, s.avatar, ol.operation_id
      FROM operation_logs AS ol
        LEFT JOIN logs AS l
          ON ol.log_id = l.id
        LEFT JOIN users AS s
          ON l.user_id = s.id

      WHERE ol.operation_id IN (#{operations_id})
      ORDER BY l.created_at DESC
    ")

    records_services = RecordService.where(record_id: @current_record).order('created_at DESC')

    transactions = CompanyTransaction.find_by_sql("
      SELECT company_transactions.*, transactions.*, categories.name AS category_name, categories.budget
      FROM company_transactions 
        INNER JOIN transactions ON company_transactions.id = transactions.company_transaction_id
        INNER JOIN categories ON company_transactions.category_id = categories.id
        INNER JOIN operations ON company_transactions.operation_id = operations.id
        
      WHERE company_transactions.operation_id IN (#{operations_id})
      ORDER BY transactions.date DESC
    ")
    discounts = Discount.where(record_client_id: records_clients).order('created_at DESC')
    records_clients = RecordClient.joins(:record)
      .select(' records.id AS id, name, abon_period, finished_at, 
                records_clients.created_at as create_records_client, 
                record_type, visit_type, 
                is_active, client_id, records_clients.id as record_client_id')
      .order('is_active DESC, create_records_client DESC, finished_at DESC')
      .where record_id: @current_record

    data = { 
      logs: logs,
      operations: operations,
      people: people,
      clients: clients,
      records: @current_record, 
      subscriptions: subscriptions,
      reminders: reminders,
      affiliates: @current_affiliates,
      categories: @categories_company,
      records: @current_record,
      records_services: records_services,
      transactions: transactions,
      discounts: discounts,
      records_clients: records_clients,
    }

    respond_to do |format|
      format.json { render json: data, status: :ok }
    end
  end
  
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
          @categories_company = Category.where("subject = 'company' AND (company_id IS NULL OR company_id = #{@current_company.id})").order(:id)

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
