class CompaniesController < ApplicationController
  before_action :ensure_current_user
  before_action :confirm_actions, except: [:new, :create]

  def company
    unless @user_director or @user_administrator
      return redirect_to request.referer, notice: "Для этого действия, у вас нет нужного уровня доступа"
    end

    @new_affiliate = Affiliate.new company_id: @current_company.id
    @new_service = Service.new company_id: @current_company.id

    @affiliates_company = Affiliate.where company_id: @current_company
    @services_company = Service.where company_id: @current_company
  end
  
  # GET /companies
  # GET /companies.json
  def index
    @companies = Company.where(user: current_user)
    
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
    @company = Company.find(params[:id])
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
  end

  def create
    @company = Company.new(company_params)

    @company.record_limit = 200
    @company.time_limit = Date.today + 14
    @company.note = "Пробный период"

    success_saving = ActiveRecord::Base.transaction do
      raise ActiveRecord::Rollback unless @company.save
      user = company_params[:user]

      affiliate = Affiliate.create(address: params[:company][:address], company_id: @company.id)

      operation = Operation.create
      people = Client.create(
        first_name: user.first_name, last_name: user.last_name, 
        company_id: @company.id, sex: 0, 
        user_id: user.id, role: (Client::Role::STUFF).to_s(2).to_i,
        operation_id: operation.id)

      operation.update_attribute(:client_id, people.id)

      user.update_attribute(:people_id, people.id)

      operation_work = Operation.create
      Work.create(position_work: :director, people_id: people.id, affiliate_id: affiliate.id,
                  operation_id: operation_work.id)

      # user.role |= User::Role::COMPANY_OWNER
      user.save!
    end

    respond_to do |format|
      if success_saving
        format.html { redirect_to root_path, notice: t('company.created') }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to @company, notice: t('company.updated') }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  # def destroy
  #   @company.destroy
  #   respond_to do |format|
  #     format.html { redirect_to companies_url, notice: t('company.destroyed') }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      params.require(:company).permit(:name).merge(user: current_user)
    end

    def ensure_company_owner
      redirect_to action: :new if current_user.role & User::Role::COMPANY_OWNER == 0
    end
end
