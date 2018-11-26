class ClientsController < ApplicationController
  before_action :ensure_current_user, :ensure_company_owner_role, only: [:index, :new, :edit, :update, :destroy]
  before_action :ensure_user_has_company
  before_action :set_s3_direct_post, only: [:new, :edit]
  before_action :confirm_actions, only: [:create, :update, :destroy, :archive, :role_employee, :role_client, :new, :edit]
  before_action :set_client, only: [:show, :edit, :update, :destroy, :archive]

  def add_field
    @new_block = InfoBlock.new
    @new_template_field = FieldTemplate.new
    @blocks_clients = InfoBlock.where(company_id: @current_company.id, model_object: 'clients')
    @field_templates_clients = FieldTemplate.where(info_block_id: @blocks_clients)
  end

  def get_fields_client
    client_id = params[:client_id]

    if Client.exists? company_id: @current_company.id, id: client_id
      field_data = InfoBlock.find_by_sql("
        SELECT ib.*, ft.client_id, json_agg(ft.*) AS values
        FROM info_blocks AS ib
          LEFT JOIN ( SELECT  fd.id AS fd_id, fd.value, fd.field_id, fd.client_id,
                              ft.id AS ft_id, ft.name AS title, ft.is_active, ft.info_block_id
                      FROM field_data AS fd
                        LEFT JOIN field_templates AS ft
                          ON fd.field_id = ft.id
                      WHERE fd.client_id = #{client_id} AND fd.value != ''
                      ORDER BY fd.id
            ) AS ft 
            ON ib.id = ft.info_block_id
        WHERE ib.company_id = #{@current_company.id} 
              AND ib.model_object = 'clients'
        GROUP BY ib.id, ft.client_id
      ")
      respond_to do |format|
        format.json { render json: field_data, status: :ok }
      end
    end
  end

  def new
    @client = Client.new company_id: @current_company.id, role: (Client::Role::CLIENT).to_s(2).to_i
    @new_block = InfoBlock.new
    @new_template_field = FieldTemplate.new
    @blocks_clients = InfoBlock.where(company_id: @current_company.id, model_object: 'clients')
    @field_templates_clients = FieldTemplate.where(info_block_id: @blocks_clients).order("id")
    @new_field_data = FieldDatum.new
    # 1.times { @client.field_data.build }

    @title_card = 'Добавление клиента'
    @form_submit = 'Сохранить'
  end

  def edit
    @client_new = Client.new company_id: @current_company.id
    @new_block = InfoBlock.new
    @new_template_field = FieldTemplate.new
    @blocks_clients = InfoBlock.where(company_id: @current_company.id, model_object: 'clients')
    @field_templates_clients = FieldTemplate.where(info_block_id: @blocks_clients).order("id")
    @new_field_data = FieldDatum.new 
    # 1.times { @client.field_data.build }

    @title_card = 'Редактирование клиента'
    @form_submit = 'Изменить'
  end

  def create
    prms = client_params
    @client = Client.new(prms)
    @client.role = (Client::Role::CLIENT).to_s(2).to_i
    
    operation = Operation.create
    @client.operation_id = operation.id

    respond_to do |format|
      if @client.save
        email = params[:client][:email]
        operation.update_attribute(:client_id, @client.id)

        account = User.find_by(email: email)
        if account.present?
          @client.update_attribute(:user_id, account.id)
          unless account.people_id.present?
            account.update_attribute(:people_id, @client.id)
          end
        end

        format.html { redirect_to "/clients?client=#{@client.id}", notice: t('client.created') }
        format.json { render :show, status: :created }
      else
        format.html { ensure_current_user; set_s3_direct_post; render :new } #   redirect_to request.referer
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  def update

    respond_to do |format|
      if @client.update(client_params)
        email = params[:client][:email]

        account = User.find_by(email: email)
        if account.present?
          @client.update_attribute(:user_id, account.id)
          unless account.people_id.present?
            account.update_attribute(:people_id, @client.id)
          end
        end
        
        format.html { redirect_to "/clients?client=#{@client.id}", notice: t('client.updated') }
        format.json { render :show, status: :ok, location: @client }
      else
        format.html { render :edit }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy 
    @client.destroy
    respond_to do |format|
      format.html { redirect_to company_clients_url, notice: t('client.destroyed') }
      format.json { head :no_content }
    end
  end

  def archive 
    @client.archive = params[:archive_status] == '1'
    @client.save!
    respond_to do |format|
      format.html { redirect_to company_client_path(@current_company.id, params[:id]) }
      format.json { render :show, status: :ok, location: @client }
    end
  end

  def role_employee 
    people = Client.find params[:id]
    if (people.role.to_i & Client::Role::STUFF) == 0
      new_role = people.role.to_i + (Client::Role::STUFF).to_s(2).to_i
      people.update_attribute(:role, new_role)
      redirect_to company_client_path(@current_company.id, params[:id]), notice: "#{people.last_name} #{people.first_name} получает роль \"Сотрудник\""
    elsif (people.role.to_i & Client::Role::CLIENT) > 0
      redirect_to company_client_path(@current_company.id, params[:id]), notice: "Человек уже является сотрудником"
    else
      redirect_to company_client_path(@current_company.id, params[:id]), notice: "Не удалось изменить роль"
    end
  end

  def role_client
    people = Client.find params[:id]
    if (people.role.to_i & Client::Role::CLIENT) == 0
      new_role = people.role.to_i + (Client::Role::CLIENT).to_s(2).to_i
      people.update_attribute(:role, new_role)
      redirect_to company_client_path(@current_company.id, params[:id]), notice: "#{people.last_name} #{people.first_name} получает роль \"Клиент\""
    elsif (people.role.to_i & Client::Role::CLIENT) > 0
      redirect_to company_client_path(@current_company.id, params[:id]), notice: "Человек уже является клиентом"
    else
      redirect_to company_client_path(@current_company.id, params[:id]), notice: "Не удалось изменить роль"
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find_by(company_id: @current_company.id, id: params[:id])
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
