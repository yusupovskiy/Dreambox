class WorkersController < ApplicationController
  before_action :confirm_actions, only: [:create, :update, :destroy, :new, :edit]
  before_action :set_s3_direct_post, only: [:new, :edit]
  before_action :set_worker, only: [:show, :edit, :update, :destroy, :archive]
  
  def index
  end

  def get_workers
    # people_company = Client.where(company: @current_company.id)
    # workers = people_company
    #             .where("(role & #{Client::Role::STUFF}) != 0")
    #             .select('clients.*')


    workers = Subscription.find_by_sql("
      SELECT c.id,
        concat(c.last_name, ' ', c.first_name, ' ', c.patronymic) AS full_name, 
        c.last_name, c.first_name, c.patronymic,
        c.birthday, c.phone_number, c.archive, c.sex, 
        c.avatar, c.role, c.operation_id

      FROM clients AS c
      WHERE (role & #{Client::Role::STUFF}) != 0
        AND c.company_id = #{@current_company.id}
      GROUP BY c.id
      ORDER BY c.first_name, c.last_name, c.patronymic
    ")

    respond_to do |format|
      format.json { render json: workers, status: :ok }
    end
  end

  def show
  end

  def new
    @worker = Client.new company_id: @current_company.id, role: (Client::Role::STUFF).to_s(2).to_i

    @title_card = 'Добавление сотрудника'
    @form_submit = 'Сохранить'
  end

  def edit

    @title_card = 'Редактирование клиента'
    @form_submit = 'Изменить'
  end

  def create
    prms = client_params
    @worker = Client.new(prms)

    email = params[:client][:email]

    account = User.find_by(email: email)
    if account.present?
      @worker.user_id = account.id
    end

    @worker.role = (Client::Role::STUFF).to_s(2).to_i

    operation = Operation.create
    @worker.operation_id = operation.id

    respond_to do |format|
      if @worker.save
        format.html { redirect_to "/workers?worker=#{@worker.id}", notice: t('client.created') }
        format.json { render :show, status: :created }
      else
        format.html { ensure_current_user; set_s3_direct_post; render :new } #   redirect_to request.referer
        format.json { render json: @worker.errors, status: :unprocessable_entity }
      end
    end
  end

  def update

    respond_to do |format|
      if @worker.update(client_params)
        email = params[:client][:email]

        account = User.find_by(email: email)
        if account.present?
          @worker.update_attribute(:user_id, account.id)
          unless account.people_id.present?
            account.update_attribute(:people_id, @worker.id)
          end
        end
        
        format.html { redirect_to "/workers?worker=#{@worker.id}", notice: t('client.updated') }
        format.json { render :show, status: :ok, location: @worker }
      else
        format.html { render :edit }
        format.json { render json: @worker.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_worker
      @worker = Client.find_by(company_id: @current_company.id, id: params[:id])
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def client_params
      res = params.require(:client)
        .permit(:first_name, :last_name, :patronymic, 
                :birthday, :phone_number, :sex, :avatar,
                field_data_attributes: [:id, :field_id, :value])
        .merge(company_id: @current_company.id)

      res[:avatar] = nil if params[:client][:avatar].blank?
      res
    end
    def set_s3_direct_post
      args = {
          key: "images/#{SecureRandom.uuid}/${filename}",
          success_action_status: '201',
          acl: 'public-read'
      }
      @s3_direct_post = S3_BUCKET.presigned_post(args)
    end
end
